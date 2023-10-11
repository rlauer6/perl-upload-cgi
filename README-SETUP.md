# README-SETUP.md

This is the README file that will explain how to create an environment
to test the POC.

# How the POC Works

See [README.md](README.md) for more details on how the POC works,
however as a reminder...

* an HTML page with an upload for is created by visiting
  `/upload/form`. This forms allows a user to upload files to a
  webserver (and eventually Amazon S3). The page is constructed using
  some Javascript and Bootstrap elements.
* files are uploaded to a local directory on the web server. The
  directory is monitored by a Linux `inotify` process.
* the `inotify` process responds to files being placed in the watched
  directory by uploading them to Amazon S3.  This process is
  implemented using
  [`Workflow::Inotify`](https://metacpan.org/pod/Workflow::Inotify)
  and the Perl module included in this project
  [`Workflow::S3::Uploader`](src/main/perl/lib/Workflow/S3/Uploader.pm.in).
* a Redis cache is used to store the progress of files as they being
  uploaded. The upload page uses Ajax calls to retrieve status
  information regarding each file's upload progress from the Redis
  cache
* Javascript on the upload page updates the Bootstrap progress bars
  using the data return by the Ajax call to retrieve file upload progress

# Requirements

* A web server running Apache and `mod_perl`
* A Redis server
* [Localstack](https://localstack.cloud/) running on port 4566 (used to mock Amazon S3)

# Perl Module Requirements

Module versions reflect what I test against in my dev environment.
Unless specifically indicated by >= you may find that using earlier
versions of these modules will also work.

| Module | Version |
| ------ | ------- |
| Amazon::Credentials | '1.1.16' |
| Amazon::S3          | '0.59' |
| Class::Accessor::Fast | '0.51' |
| Config::IniFiles    | '3.000003' |
| Data::UUID          | '1.226' |
| Date::Format        | '2.24' |
| File::HomeDir       | '1.006' |
| JSON                | '4.07' |
| Linux::Inotify2     | '2.3' |
| List::Util          | '>=1.33  |
| Log::Log4perl       | '1.55' |
| Log::Log4perl::Level | - |
| Number::Bytes::Human | '0.11' |
| Readonly             | '2.05' |
| Redis                | '1.999' |
| Template             | '3.100' |
| Workflow::Inotify | '1.0.2' |

# Building and Installing the Project

1. Build the package
1. Install the package on an Apache web server
1. Start your Redis server
1. Start LocalStack (if you are mocking the S3 service)
1. Start the `inotify` daemon

The following description assumes you are running the POC in a
Dockerized enviroment using the `docker-compose` configuration
provided in the project.

Login to the web server.

```
docker exec -it docker_web_1 /bin/bash
```

A script ([build](build)) has been provided that you can run after
producing a tarball and copying it to your web server. See [Building
the Distribution Package](#building-the-distribution-package)) for
details on how to create a tarball.

Hint: I typically map a local temporary directory to the Docker container's
 `/tmp/scratch` directory and copy the tarball and the `build` script there.

```
 #!/usr/bin/env bash
 #
 # script to provision container w/Perl dependencies
 #
 # after bringing up the Docker compose stack...
 
 tarball=$(ls -1 /tmp/scratch/perl-upload*.tar.gz 2>/dev/null | tail -1)
 
 if test -z "$tarball"; then
     >&2 echo "no tarball found"
     exit
 fi
 
 tar xfv $tarball
 
 tarball=$(basename $tarball)
 
 cd ${tarball%%.tar.gz}
 
 if [ "$1" = "cpan" ]; then
     ./configure \
         --disable-perldeps \
         --disable-deps
     
     make cpan
 elif test -z "$1"; then
 
     ./configure \
         --with-apache-vhostdir=/var/www \
         --with-apache-port=8080 \
         --with-apache-loglevel=trace8 \
         --sysconfdir=/etc \
         --localstatedir=/var \
         --with-s3-host=http://s3.localhost.localstack.cloud:4566 \
         --with-bucket-prefix=uploads \
         --with-redis-server=redis \
         --enable-apache-log-console
 
     make && make install
     
     AWS_ACCESS_KEY_ID=test \
     AWS_SECRET_ACCESS_KEY=test \
       inotify.pl --config /etc/workflow/config.d/upload.cfg
 fi
```

Install Perl dependencies from CPAN first...

```
/tmp/scratch/build cpan
```

Then install the application...

```
/tmp/scratch/build
```

After running the `build` scripts `graceful`ly restart Apache. Note
that if you use `restart` instead of `graceful` you will be booted out
of the container..

```
apachectl graceful
```
Check the status of the `inotify` process which uploads files to
LocalStack.

```
ps -ef | grep inotify
```

Check the log file for any errors.

```
less /var/log/perl-upload-cgi.log
less /var/www/log/perl-upload-cgi.log
```
# Hints and Reminders

## Running in a Dockerized Environment

```
version: "3.9"
services:
  redis:
    image: redis/redis-stack-server
    networks:
      default:
        aliases:
          - redis
    environment:
      - ALLOW_EMPTY_PASSWORDS=yes
  localstack:
    container_name: "${LOCALSTACK_DOCKER_NAME-localstack_main}"
    image: localstack/localstack
    hostname: s3
    networks:
      default:
        aliases:
          - s3.localhost.localstack.cloud
          - test-bucket.s3.localhost.localstack.cloud
    #network_mode: bridge
    ports:
      - "127.0.0.1:4510-4530:4510-4530"
      - "127.0.0.1:4566:4566"
      - "127.0.0.1:4571:4571"
    environment:
      - SERVICES=s3
      - DEBUG=${DEBUG-}
      - DATA_DIR=${DATA_DIR-}
      - HOST_TMP_FOLDER=${TMPDIR:-/tmp/}localstack
      - DOCKER_HOST=unix:///var/run/docker.sock
    volumes:
      - "${LOCALSTACK_VOLUME_DIR:-./volume}:/var/lib/localstack"
      - "/var/run/docker.sock:/var/run/docker.sock"
  web:
    read_only: false
    build:
      context: ${PWD}
      dockerfile: ${PWD}/Dockerfile
    image: "perl-upload-cgi:latest"
    ports:
      - '8080:8080'
    expose:
      - 8080
    entrypoint: ["/usr/sbin/apachectl", "-D", "FOREGROUND"]
    volumes:
      - ${PWD}/httpd.conf:/etc/httpd/conf/httpd.conf
      - ${HOME:?set HOME}/scratch:/tmp/scratch
```

## Create an Upload Bucket

> The test bucket will automatically be created for you if it does not
> exist if you set the `create_bucket` variable in the
> `/etc/workflow/config.d/upload.cfg` file to a true value.

```
aws s3 \
  --endpoint-url http://localhost:4566 \
  --profile localstack \
  mb s3://test-bucket
```

## Chromebook

If you want to use your Chromebook browser to access the webserver,
you must port forward 8080. You can do this by accessing the
_Advanced>Developers>Linux development environment settings_.

## Building the Distribution Package

To build the package in your development environment you'll need
`automake`, `make`, and `autoconf`.  You __do not__ need these tools
on the target server.

```
./bootstrap
./configure
make && make dist
```

This will create a tarball that you can install on your target server.

Unpack the tarball and configure the software with optional arguments.

| Option | Description |
| ------ | ----------- |
| `--with-bucket-name` | name of the bucket where files will be uploaded |
| `--with-bucket-prefix` | prefix to use when storing the file to the bucket |
| `--with-s3-host` | endpoint url of the S3 service |
|             | default: `s3.amazonaws.com` |
| `--with-profile` | Amazon profile - leave blank if using credentials from instance or environment |
| `--with-apache-vhostdir` | root directory of web server |
| | default: `/var/www` |
| `--with-redis-server` | name of the Redis server default: `localhost` |
| `--with-redis-port` | port for the Redis server default: `6379` |
| `--enable-apache-log-console` | output Apache log files to console |
| `--with-apache-loglevel`  | configure Apache's `LogLevel` directive |

```
$ tar xfvz perl-upload-cgi-1.0.0.tar.gz
$ cd perl-upload-cgi
$ ./configure --localstatedir=/var --sysconfdir=/etc \
    --with-bucket-name=s3-bucket-name \
    --with-bucket-prefix=/uploads \
    --with-redis-server=localhost \
    --with-redis-port=6379 \
    --with-s3_host=s3.localhost.localstack.cloud \
    --with-profile=localstack
```

The `configure` script will check to see if you have the required Perl
modules.  If some are missing you can install them using `cpanm` as
shown below.

_Note that `make cpan`  will install the *latest* version of all
of the dependencies, possibly upgrading modules you already have
installed!  If you do not want this to occur, you should note the
missing dependencies one by one and install them individually._

```
make cpanm && make cpan
```

Once `configure` successfully completes, you can now build and install
the software.

```
make && sudo make install
```

The build tree will look something like this:

```
 etc
 |-- systemd
 |   `-- system
 |       `-- inotify.service
 `-- workflow
     `-- config.d
         `-- upload.cfg
 usr
 `-- local
     `-- share
         |-- man
         |   `-- man1
         |       |-- upload.1man
         |       `-- Uploader.1man
         |-- perl5
         |   `-- Workflow
         |       `-- S3
         |           `-- Uploader.pm
         `-- perl-upload-cgi
             `-- templates
                 `-- upload-form.tt
 var
 |-- spool
 |   `-- perl-upload-cgi
 `-- www
     |-- cgi-bin
     |   `-- upload.cgi
     |-- config
     |   `-- upload.json
     |-- htdocs
     |   |-- css
     |   |-- images
     |   `-- javascript
     |       `-- upload.js
     |-- include
     |   `-- upload-form.tt
     `-- log

```

# Configuring and Enabling the Inotify Script

An `inotify` processs is used to monitor the upload directory. When
files are dropped into the directory, the process will upload the file
to the S3 bucket specified in the `upload.cfg` configuration file. 

On a system that uses `systemd` to launch services, you can use the
service installed for you as part of this project.

```
sudo systemctl start inotify
```

# `systemd` tips

| Function | Command | 
| -------- | ------- |
| Start service | `systemctl start inotify` |
| Stop service | `systemctl stop inotify` |
| Reload (SIGHUP) | `systemctl reload inotify` |
| Daemon reload  (required when configuration changes) | `systemctl daemon-reload` |

If you don't have `systemd` available or you are running inside a
Docker container, you can launch the script
manually.

```
sudo /usr/local/bin/inotify.pl \
   --config=/etc/workflow/config.d/upload.cfg
ps -ef | grep inotify
```

The process will log to two files. During the initialization phase a
log file is written to `/var/log/perl-upload-cgi.log`. Shortly after
launching, logs are written to `/var/www/log/perl-upload-cgi.log`.

# Redis

If you are not running the `docker-compose` configuration but want to
run Redis in a local Docker container you can start Redis as shown below.

```
docker run -d \
  --name redis-stack-server \
  -p 6379:6379 \
  redis/redis-stack-server:latest
```

To connect from the other Docker containers:

On host system (assuming you have `jq` installed):

```
redis_ip=$(docker inspect $(docker ps -a | grep redis | awk '{print $1}') | \
  jq -r '.[]|.NetworkSettings.Networks.bridge.IPAddress')

```

```
redis-cli -h 172.17.0.2
```
