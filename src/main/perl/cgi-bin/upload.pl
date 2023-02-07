#!/usr/bin/env perl

use strict;
use warnings;

use Carp;
use CGI;
use Class::Accessor::Fast;
use Data::Dumper;
use Data::UUID;
use Date::Format qw(time2str);
use Digest::MD5 qw(md5_hex);
use English qw(-no_match_vars);
use File::Basename qw(fileparse);
use JSON;
use List::Util qw(pairs);
use Log::Log4perl qw(:easy);
use Number::Bytes::Human qw(format_bytes);
use Redis;
use Template;
use Time::HiRes qw(gettimeofday);

use Readonly;

Readonly our $CONFIG_PATH => '/var/www/config';

Readonly our $TRUE  => 1;
Readonly our $FALSE => 0;

Readonly our $EMPTY       => q{};
Readonly our $SLASH       => q{/};
Readonly our $EQUALS_SIGN => q{=};

Readonly::Hash our %LOG_LEVELS => (
  error => $ERROR,
  warn  => $WARN,
  info  => $INFO,
  debug => $DEBUG,
  trace => $TRACE,
);

our $VERSION = '0.001';

########################################################################
sub main {
########################################################################

  my $config = get_config($PROGRAM_NAME);

  Log::Log4perl->easy_init(
    { level  => $LOG_LEVELS{ $config->get_log->{level} // 'info' },
      layout => $config->get_log->{layout} // '[%d] (%r/%R) %M:%L - %m%n',
      file   => $config->get_log->{file},
    }
  );

  my $logger = Log::Log4perl->get_logger();

  $logger->info( Dumper($config) );

  my $redis = eval {
    return Redis->new(
      server => sprintf '%s:%s',
      @{ $config->{redis} }{qw(server port)}
    );
  };

  if ( !$redis || $EVAL_ERROR ) {
    $logger->error( 'could not initialize redis client: ' . $EVAL_ERROR );
    exit http_error(500);
  }

  if ( $ENV{REQUEST_METHOD} eq 'GET' ) {
    api_request(
      config => $config,
      redis  => $redis,
      logger => $logger
    );
  }
  else {
    upload(
      config => $config,
      redis  => $redis,
      logger => $logger
    );
  }

  exit 0;
}

########################################################################
sub http_error {
########################################################################
  my ( $error, $message ) = @_;

  return print "Status: $error $message\n\n";
}

########################################################################
sub api_request {
########################################################################
  my %args = @_;

  my ( $redis, $logger, $config ) = @args{qw(redis logger config)};

  my $cgi = CGI->new;

  my $session_id = get_session_id($config) // uuid();

  my $action = $cgi->param('action');
  $action //= 'show-form';

  $logger->info( Dumper( [ 'action', $action, 'session_id', $session_id ] ) );

  my %request = (
    'initialize-upload' => \&initialize_upload,
    'fetch-status'      => \&fetch_status,
    'show-form'         => \&show_form,
  );

  if ( !$request{$action} ) {
    exit http_error( 403, 'Bad Request' );
  }

  return $request{$action}->(
    %args,
    session_id => $session_id,
    cgi        => $cgi,
  );
}

########################################################################
sub fetch_status {
########################################################################
  my (%args) = @_;

  my ( $redis, $session_id, $cgi, $logger )
    = @args{qw(redis session_id cgi logger)};

  my $file_list = decode_json( $redis->get($session_id) // '{}' );

  $logger->info( Dumper( [ 'file_list', $file_list ] ) );

  my %status;

  if ( keys %{$file_list} ) {
    my %files;

    for ( keys %{$file_list} ) {
      $files{$_} = decode_json( $redis->get($_) || '{}' );
    }

    $status{files} = \%files;
    $status{error} = $EMPTY;
  }
  else {
    $status{error} = 'not found';
  }

  $logger->info( Dumper( \%status ) );

  return output_json( \%status );
}

########################################################################
sub initialize_upload {
########################################################################
  my (%args) = @_;

  my ( $redis, $cgi, $session_id, $logger, $config )
    = @args{qw(redis cgi session_id logger config)};

  my $file_map = {};

  my @ts = gettimeofday();

  my @files;

  my $size      = $cgi->param('size');
  my $filename  = $cgi->param('filename') // $EMPTY;
  my $file_list = $cgi->param('file_list');         # array of file objects
  my $index     = $cgi->param('index');

  if ($file_list) {
    @files = @{ serialize($file_list) };
  }
  else {
    push @files,
      {
      filename => $filename,
      size     => $size,
      index    => $index,
      };
  }

  $logger->debug( sub { return Dumper( [@files] ) } );

  for (@files) {
    my $file_id = md5_hex( $_->{filename}, $session_id );

    my $status = {
      session_id => $session_id,
      filename   => $_->{filename},
      size       => $_->{size},
      index      => $_->{index},
      init_time  => \@ts,
      size_human => format_bytes( $_->{size} ),
    };

    $file_map->{$file_id} = $status;

    $redis->set( $file_id, serialize($status) );
  }

  $redis->set( $session_id, serialize($file_map) );

  expire_upload(
    key    => $session_id,
    type   => 'session',
    config => $config,
    redis  => $redis
  );

  $logger->info( sub { return Dumper( [$file_map] ) } );

  return output_json($file_map);
}

########################################################################
sub upload {
########################################################################
  my %args = @_;

  my ( $redis, $logger, $config ) = @args{qw(redis logger config)};

  my $session_id = get_session_id($config);

  if ( !$session_id ) {
    print "Status: 401 Unauthorized\n\n";
    return;
  }

  my @start_time = gettimeofday();

  my $start_time_microseconds = $start_time[0] * 1_000_000 + $start_time[1];

  my $cgi = CGI->new(
    \&hook,
    { logger     => $logger,
      redis      => $redis,
      start_time => $start_time_microseconds,
      session_id => $session_id,
      config     => $config,
    }
  );

  my $status = serialize( $redis->get($session_id) || {} );

  my $filename = $cgi->upload('filename');

  my $file_id   = md5_hex( "$filename", $session_id );
  my $file_info = serialize( $redis->get($file_id) );

  $logger->info(
    Dumper(
      [ 'file_info', $file_info,  'status', $status,
        'filename',  "$filename", 'cgi',    $cgi
      ]
    )
  );

  if ($filename) {
    $file_info->{temp_filename} = $filename->filename;

    rename $filename->filename, $config->get_upload->{path} . "/$filename";

    $file_info = serialize($file_info);
  }
  else {
    $file_info = serialize( { error => 'not sure what happened here?' } );
  }

  print "Content-type: application/json\n\n";
  print "$file_info\n";

  return;
}

########################################################################
sub serialize {
########################################################################
  my ($obj) = @_;

  return ref $obj ? encode_json($obj) : decode_json($obj);
}

########################################################################
sub get_session_id {
########################################################################
  my ($config) = @_;

  my $cookie_name = $config->get_session->{cookie_name};

  my ($session_id) = grep {/$cookie_name/xsm} split /;/xsm,
    $ENV{HTTP_COOKIE} // $EMPTY;

  return
    if !$session_id;

  if ($session_id) {
    $session_id = ( split /=/xsm, $session_id )[1];
  }

  return $session_id;
}

########################################################################
sub hook {
########################################################################
  my ( $filename, $buffer, $bytes_read, $data ) = @_;

  my $logger = $data->{logger};
  my $redis  = $data->{redis};
  my $config = $data->{config};

  my $session_id = $data->{session_id};

  my $file_id = md5_hex( $filename, $session_id );

  $logger->trace("fetching $file_id");

  my $status = $redis->get($file_id) || '{}';

  $status = serialize($status);

  my $start_time_microseconds = $data->{start_time};

  my @now_time = gettimeofday();

  my $now_time_microseconds = $now_time[0] * 1_000_000 + $now_time[1];

  my $elapsed_time = $now_time_microseconds - $start_time_microseconds;
  $elapsed_time = $elapsed_time > 0 ? int( $elapsed_time / 1_000 ) : 0;

  $status->{bytes_read}             = $bytes_read;
  $status->{elapsed_time}           = $elapsed_time;
  $status->{elapsed_time_formatted} = sprintf '%5.3f', $elapsed_time / 1000;
  $status->{pid}                    = $PID;
  $status->{percent_complete}       = int 100 * $bytes_read / $status->{size};

  $logger->trace( "setting $file_id to " . serialize($status) );

  $redis->set( $file_id, serialize($status) );

  expire_upload(
    key    => $file_id,
    type   => 'file',
    config => $config,
    redis  => $redis
  );

  expire_upload(
    key    => $session_id,
    type   => 'session',
    config => $config,
    redis  => $redis
  );

  $logger->trace(
    Dumper(
      [ length($buffer), $filename, $bytes_read, $ENV{CONTENT_LENGTH}, ]
    )
  );

  return $TRUE;
}

########################################################################
sub expire_upload {
########################################################################
  my (%args) = @_;

  my ( $redis, $config, $key, $type ) = @args{qw(redis config key type)};

  my $timeout = time + $config->get_upload->{timeout}->{$type};

  return $redis->expireat( $key, $timeout );
}

########################################################################
sub output_json {
########################################################################
  my ($json) = @_;

  if ( ref $json ) {
    $json = encode_json($json);
  }

  return print "Content-type: application/json\n\n$json";
}

########################################################################
sub show_form {
########################################################################
  my (%args) = @_;

  my ( $session_id, $config ) = @args{qw(session_id config)};

  my $tt = Template->new(
    { INCLUDE_PATH => $config->get_template->{include_path},
      ABSOLUTE     => $config->get_template->{absolute},
      INTERPOLATE  => $config->get_template->{interpolate},
    }
  );

  my $parameters = { session_id => $session_id };

  my $content  = $EMPTY;
  my $template = $config->{template}->{'upload-form'};

  $tt->process( $template, $parameters, \$content );
  $content ||= '<pre>error: ' . $tt->error() . '</pre>';

  my $expiry_date
    = time2str( '%a, %d-%b-%Y %H:%M:%S GMT', time + 60 * 60 * 15 );

  print "Content-Type: text/html\n";

  print bake_cookie(
    _user    => 'rob',
    SameSite => $EMPTY,
    Secure   => undef,
    path     => $SLASH,
    expires  => $expiry_date,
  );

  my $cookie_name = $config->get_session->{cookie_name};

  print bake_cookie(
    $cookie_name => $session_id,
    SameSite     => $EMPTY,
    Secure       => undef,
    path         => $SLASH,
    expires      => $expiry_date,
  );

  return print "\n$content";
}

########################################################################
sub uuid {
########################################################################
  my $ug = Data::UUID->new;

  return $ug->to_string( $ug->create() );
}

########################################################################
sub get_config {
########################################################################
  my ($config_name) = @_;

  my ( $name, $path ) = fileparse( $config_name, qr{[.][^.]+$}xsm );

  local $RS = undef;
  my $config_path = $ENV{CONFIG_PATH} || $CONFIG_PATH;

  my $config_file = $CONFIG_PATH . "/$name.json";

  open my $fh, '<', $config_file
    or croak "could not open $config_file";

  my $config = eval { return decode_json(<$fh>); };

  close $fh;

  croak "invalid configuration file\n$EVAL_ERROR"
    if !$config;

  bless $config, 'MyConfig';

  {
    no strict 'refs'; ## no critic (ProhibitNoStrict)

    use Class::Accessor::Fast;

    @{'MyConfig::ISA'} = qw(Class::Accessor::Fast);
  }

  $config->follow_best_practice();
  $config->mk_ro_accessors( keys %{$config} );

  return $config;
}

########################################################################
sub bake_cookie {
########################################################################
  my (@cookie) = @_;

  my $cookie = join '; ',
    map { defined $_->[1] ? $_->[0] . $EQUALS_SIGN . $_->[1] : $_->[0] }
    pairs @cookie;

  return "Set-Cookie: $cookie\n";
}

main();

1;

__END__
