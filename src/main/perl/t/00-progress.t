#!/usr/bin/env perl

use strict;
use warnings;

use English qw(-no_match_vars);

use Test::More tests => 29;

use_ok('Apache2::Upload::Progress');

use Apache2::Upload::Progress qw(:validators boolean);

for my $bool (qw(1 yes on true)) {

  ok( v_is_boolean( 'name', $bool ),
    sprintf '"%s" is a boolean (true)', $bool )
    or diag(
    sprintf '[%s], [%s], [%s]', boolean($bool),
    v_is_boolean($bool),        $EVAL_ERROR
    );
}

for my $bool (qw(0 no off false)) {
  ok( v_is_boolean( 'name', $bool ),
    sprintf '"%s" is a boolean (false)', $bool )
    or diag(
    sprintf '[%s], [%s], [%s]', boolean($bool),
    v_is_boolean($bool),        $EVAL_ERROR
    );
}

my $bool = 'si';

for my $bool (qw(si none yup 43)) {
  ok( !v_is_boolean( 'name', $bool ),
    sprintf '"%s" is a not a boolean', $bool )
    or diag(
    sprintf '[%s], [%s], [%s]', boolean($bool),
    v_is_boolean($bool),        $EVAL_ERROR
    );
}

ok( v_is_dir( 'path', '/tmp' ), 'valid dir' );

ok( !v_is_dir( 'path', '/foo' ), 'is not a valid dir' );

ok( v_is_num( 'num',  123 ),   'is a valid number' );
ok( !v_is_num( 'num', 'foo' ), 'is not a valid number' );

ok( v_is_num( 'num', 123, 0, 125 ), 'is a valid number in range (0,125)' );
ok( v_is_num( 'num', 123, 0 ),      'is a valid number in range (0,...' );
ok( !v_is_num( 'num', 123, 0, 10 ), 'is a invalid number in range (0, 10)' );

ok( v_is_byte_str( 'num',  1024 * 1024 ), 'is a valid byte string' );
ok( v_is_byte_str( 'num',  '1GB' ),       'is a valid byte string' );
ok( !v_is_byte_str( 'num', '1FB' ),       'is NOT a valid byte string' );
ok(
  v_is_byte_str( 'num', '1GB', 1024, '2GB' ),
  'is a valid byte string in range'
);

ok(
  v_is_valid_str(
    'str', 'abc.com',
    allowed => join q{},
    q{A} .. q{Z}, q{a} .. q{z}, q{-.}, '0' .. '9'
  ),
  'is a valid server name'
);

ok(
  !v_is_valid_str(
    'str', 'abc,.com',
    allowed => join q{},
    q{A} .. q{Z}, q{a} .. q{z}, '0' .. '9', q{-.}
  ),
  'is a NOT valid server name'
);

ok(
  !v_is_valid_str(
    'str', 'abc,.xyz', forbidden => "\t" . ' ()<>\@,;:\"/\[\]\?=\{\}'
  ),
  'is a NOT valid cookie name'
);

ok( v_is_one_of( 'select', 'rename', qw(rename symlink link copy) ),
  'is one of' );

ok( !v_is_one_of( 'select', 'xrename', qw(rename symlink link copy) ),
  'is NOT one of' );
1;
