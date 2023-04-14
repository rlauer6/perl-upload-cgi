# NAME

Apache2::Upload::Progress - mod\_perl based upload with progress monitoring

# SYNOPSIS

    APREQ2_ReadLimit 2147483648
    
    PerlLoadModule Apache2::Upload::Progress

    PerlPostReadRequestHandler Apache2::Upload::Progress

    PerlPostConfigHandler Apache2::Upload::Progress::post_config
    
    <UploadProgress>
      UploadProgressHandler Apach2::Upload::Progress:Redis>
      UploadProgressConfig apache2-upload-progress.json>
    </UploadProgress>

# DESCRIPTION

`mod_perl` handler for uploading files to a web server. This class
also provides methods for monitoring the status of file
uploads (aka a progress meter).

Upload monitoring is done by accessing a URL endpoint that will return
the JSON payload containing information about each file being
uploaded. The information for each file should be stored in a cache
which allows requests that hit any of the web servers in your
architecture to access the status information. The reference
implementation included with this project utilizes a Redis server.

The project includes a fully functional example that can be run in
Docker containers. The reference implementation will provision an
Apache web server running `mod_perl`, a Redis server and LocalStack
for emulating uploads to Amazon S3. An upload form where you can
upload files to the web server is accessed using one of the endpoints
configured by the handler.

    http://localhost:8080/upload/form

# HISTORY

_Originally written as a CGI, I decided to convert this module into a
`mod_perl` handler and provide a fully functional reference
implmentation you can run in a Docker container._

In reviewing prior art and researching `mod_perl`
handlers, I uncovered [Apache::UploadMeter](https://metacpan.org/pod/Apache%3A%3AUploadMeter) which contained a lot of
similar concepts (`mod_perl` based, ability to serve an upload form,
highly configurable...). Much of the custom Apache directive code has
been guided by the [Apache::UploadMeter](https://metacpan.org/pod/Apache%3A%3AUploadMeter) implementation.>

## Differences Between `Apache::UploadMeter` and `Apache::Upload::Progress`

- Caching

    The upload status in `Apache::UploadMeter` is implemented using
    [File::Cache](https://metacpan.org/pod/File%3A%3ACache), implying it can only be used on a single Apache
    server. `Apache::Upload::Progress` allows you to specify your own
    cache handler (the default implementation uses Redis). See ["CREATING
    YOUR OWN CACHING MECHANISM"](#creating-your-own-caching-mechanism).

- Form Handling

    Upload forms for `Apache::Upload::Progress` are based on a
    configurable template processed using
    [Template::Toolkit](https://metacpan.org/pod/Template%3A%3AToolkit). `Apache::UploadMeter` serves up a hard coded
    form which only handles a single file upload (the expectation is for
    you to modify that code for your needs). It appears one could include
    multiple forms on the page but that looks to be a bit messy.

    The reference implementation here uses Bootstrap to create as many
    upload meters as files you have to upload.

- Output Format

    `Apache::Upload::Progress` will only return JSON
    data. `Apache::UploadMeter` can deliver results as JSON or
    XML. Apparently XML was a thing back in the day.  ;-)

- Configuration

    `Apache::Upload::Progress` uses a JSON configuration file to
    customize a large part of the process, whereas `Apache::UploadMeter`
    is configured completely within the context of Apache's configuration.

    `Apache::Upload::Progress` allows you to specify the location of the
    configuration file within the context of the Apache configuration.

- Metadata

    `Apache::Upload::Progress` will optionally create a metadata file in
    JSON format describing various attributes of the uploaded file.

    Example:

        {
           "remote_addr" : "172.18.0.1",
           "tempname" : "/tmp/aprequ9PBYx",
           "name" : "filename",
           "canonical_name" : "1-Untitled_Feb_2_2022_424_PM.webm",
           "path" : "/var/www/spool/1-Untitled Feb 2, 2022 424 PM.webm",
           "upload_id" : "b295655e99277e54e3d1fc4b0239cef2",
           "size" : 173608466,
           "filename" : "Untitled Feb 2, 2022 424 PM.webm",
           "session" : "b4754d7422d65d7af578ec47da799055",
           "type" : "video/webm",
           "upload_date" : "Mon Apr 10 16:22:03 2023"
        }

- File Uploads

    File uploads are actually handled by `Apache2::Upload` for
    `Apache2::Upload::Progress` and output locations are customized in
    the configuration file. Additionally, a companion application that
    runs as a daemon is provided in this project that will allow you to
    create a handler for off-loading the uploaded file to another location
    (e.g. Amazon S3).

    To be honest, I haven't tried to install `Apache::UploadMeter` in
    order to figure out where files uploaded using that module end up.

- Support

    `Apache::UploadMeter` should work (that's an exercise I might take
    on) but was written in 2007 and does not appear to have much support
    these days.  You can find `Apache2::Upload::Progress` in my [github
    repo](https://github.com/rlauer6/perl-cgi-upload.git). Log issues there
    and as always PRs welcomed. ;-)

# VERSION

This documenation refers to version 1.1.4.

# DETAILS

## Prerequisites

- Dependencies

    Perl module dependencies are listed in the `requires.txt` file in the
    root of the project. A summary of other requirements is shown here, but may
    be incomplete.

    - Apache 2+
    - mod\_perl2
    - [Apache2::Request](https://metacpan.org/pod/Apache2%3A%3ARequest)  _including libapreq2_

        Version 2.17

    - `docker`, `docker-compose` if you want to run the reference
    implementation
    - `autoconf`, `automake` for hacking on the project

- Configuration

    A configuration file in JSON format is read once by the class when
    your Apache server is started. The file name is configured in the
    `<UploadProgress>` directive. Set the path for where that
    file can be found using the `CONFIG_PATH` environment variable. You
    should set that in your Apache configuration as shown below.

        PerlSetEnv CONFIG_PATH /var/www/config

    A sample configuration file and explanation of each variable
    follows. Note that the configuration file is subject to change. You
    can add anything you'd like here, **but don't remove top level
    sections elements**.

    Any _true_ boolean value in the configuration file can be represented as:

        1
        yes
        on 
        true

    Any _false_ boolean value in the configuration file can be represented as:

        0
        no
        off
        false

    **Sample configuration:**

        {
            "allow_edit" : "yes",
            "log4perl" : {
                "config" : [
                    "log4perl.rootLogger = DEBUG, File",
                    "log4perl.appender.File = Log::Log4perl::Appender::File",
                    "log4perl.appender.File.filename = /var/www/log/apache2_upload_progress.log",
                    "log4perl.appender.File.mode = append",
                    "log4perl.appender.File.layout = PatternLayout",
                    "log4perl.appender.File.layout.ConversionPattern=[%d] (%r/%R) %M:%L - %m%n"
                ],
                "level" : "debug"
            },
            "upload" : {
                "path" : "/var/www/spool",
                "max_file_size" : "1G",
                "temp_dir" : "/tmp",
                "timeout" : 60,
                "fix_filename": "yes",
                "metadata" : "yes",
                "store_method" : "rename"
            },
            "redis" : {
                "server" : "redis",
                "port" : "6379",
                "timeout" : 60
            },
            "template" : {
                "jquery" : {
                    "javascript" : {
                        "src" : "https://code.jquery.com/jquery-3.6.3.min.js",
                        "integrity" : "sha256-pvPw+upLPUjgMXY0G+8O0xUf+/Im1MZjXxxgOcBQBXU=",
                        "crossorigin" : "anonymous"
                    }
                },
                "bootstrap" : {
                    "stylesheet" : "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css",
                    "javascript" : {
                        "src" : "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"
                    }
                },
                "upload": {
                    "form" : "upload-form.tt",
                    "javascript" : {
                        "src" : "/javascript/upload.js"
                    },
                    "url" : "/upload",
                    "form_field" : "filename",
                    "max_files" : 15
                },
                "config": {
                    "form" : "config-form.tt",
                    "javascript": {
                        "src" : "/javascript/config.js"
                    },
                    "css": {
                      "src" : "/css/config.css"
                    },
                    "url" : "/upload/config"
                },
                "include_path" : "/var/www/include",
                "absolute" : 1,
                "interpolate" : 1
            },
            "session" : {
                "cookie_name" : "session",
                "timeout" : 15,
                "no_cookie_error" : 0
            }
        }

- log4perl

    [Log::Log4perl](https://metacpan.org/pod/Log%3A%3ALog4perl) configuration. Because the class can provide
    detailed output in debug mode and the Apache logger may be configured
    to escape new lines making it difficult to read
    ([https://stackoverflow.com/questions/1573912/why-does-my-apache2log-output-replace-newlines-with-n](https://stackoverflow.com/questions/1573912/why-does-my-apache2log-output-replace-newlines-with-n))
    a separate log file can be used instead of logging using Apache's
    logger. If you would prefer that all messages go to Apache's logs,
    remove the `config` object from the `log4perl` section. In that
    case, the class will only output debug message if Apache's log level
    is 'debug'.

- upload

    Specify various options that effect uploading files in this section.

    - path

        Set the `path` to the directory where files will be stored. Files
        will either be copied here or a hard link will be created from the
        temporary file upload to this destination. If you are storing files on
        a different file system or partition you should set the `copy` flag
        to true.

    - copy

        Boolean value that determines whether files will be copied or linked
        to the upload path.

        default: false

    - max\_file\_size

        The maximum size for file uploads. You can specify this value as a
        character string like "2M", "1G" or as an integer. This value must be
        less than the value of `APREQ2_ReadLimit`. You can set that value in
        your Apache configuration if you want to allow uploads greater than
        the defaul value of 64MB.

        Files uploaded will, by default be upload first to a temp
        directory and then moved (linked) to the path you specified. If you
        prefer that the file be copied, add a `copy` variable to this section
        set to any non-zero value.

        Example:

            copy = yes

        default: 64MB

    - metadata

        Boolean value that determines whether a metadata file will be created
        in the upload directory for each file. The metadata file will have the
        same name as the file that was uploaed with an extension of `.json`.

        default: false

    - fix\_filename

        Boolean that determines whether filenames should be _fixed_ by
        removing whitespace and other special characters. Setting this to true
        will essentially run this snippet of Perl code on the filename:

            $filename =~s/[\s\'\@!,]/_/xsm;
            while ($filename =~s/__/_/) { };

        default: false

- redis

    _The reference example utilizes a Redis server to implement caching of
    the upload status, therefore the sample configuration includes a `redis` section._

    Configure the Redis server in this section. The `timeout` value is
    the amount of time that cache entries should be allowed to exist. Once
    the client has selected a list of files and you have called the
    `upload_init` endpoint, the clock starts.

    Unless you are only using only 1 web server your Redis server should
    be run on its own host. Even if you only have 1 web server you should
    probably provision a separate host for your Redis server. Web clients
    monitoring uploads will typically make calls to the `upload_status`
    endpoint every fraction of a second or so meaning you might have
    hundreds of request coming into your server at the same time you are
    uploading data to it.

- template

    The `upload_form` endpoint can be used to deliver a web form for
    uploading files. The project contains a sample form based on Bootstrap
    that is rendered using `Template::Toolkit`. You can configure your
    own form here. `include_path` is the path where your templates will be
    found. The entire configuration is sent to
    `Template::Toolkit::process()`.  You can put anything you'd like in
    the `upload? section based on your template's needs.`

- session

    The `session` section is used to specify the cookie name that
    contains your session id. The API endpoints look for the cookie you
    specify here in order to uniquely identify the session and in most
    cases where a session cookie is used, the user performing the upload.

    The `timeout` value here is used to create the cookie and is only
    used when delivering the form if a cookie is not available (and you
    have not set the `no_cookie_error` value). The `upload_form`
    endpoint is designed to deliver an HTML snippet that might be used
    inside a larger application. If a cookie is not found it likely means
    your user's cookie has expired, hence by default a cookie will be
    fabricated and sent to the web client. In your own applications you
    probably do not want this module to create a cookie for you. In that
    case can set the value of `no_cookie_error` to a non-zero value
    (e.g. 401) to have the endpoint return an HTTP status other than 200
    rather than generating a cookie. If you subclass
    `Apache2::Upload::Progress` you can override the default cookie
    creation method to provide your own session cookie.

    See ["upload\_form"](#upload_form) for more details about how you can deliver your own
    forms using the `upload_form` endpoint.

- Sessions

    Presumably you are using this uploader as part of an application that
    may support multiple users. In order to identify uploads for
    individual clients the process looks for a cookie to use as a session
    identifier. The cookie is used as a key when storing status information
    related to that session's file uploads. The name of the cookie is
    configurable.

    If a session cookie does not exist, API calls (other than
    `/upload/form` discussed above) will return a 401 status.

    API endpoints will first look for a session cookie and if it does not
    exist, will return a 401. Next, the method that implements the API
    endpoint wil call the `validate_session()` method. You should
    subclass `Apache2::Upload::Progress` and override this method to
    provide your own session validation routine.  The method should return
    a hash reference that contains at least two members:

        session_id
        prefix

    The `upload` endpoint API will prepend the `prefix` followed by a
    dash ('-') to the front of the filename. Typically your `prefix`
    value should be a string or number that identifies the user or
    account that has uploaded the file. The identifier should only contain
    alphanumeric values.

    The daemon that is provided with this project will use the prefix part
    of the filename as part of the object key, thereby partitioning the S3
    bucket.

## The Upload Steps

The upload process should proceed as follows:

- 1. Send a list of files to be uploaded to the `upload_init`
endpoint. 

    Send a JSON array containing a hash of information for each file. The
    structure should look like this:

        [
         {
           "filename" : "somefile.png",
           "size" : 12378,
           "index" : 0,
           "type" : "video/webm"
         },
         ...
        ]

    Typically this information is the information you would get by
    accessing the document's file upload element. Using jQuery you might do
    something like the snippet below to retrieve the list.

        var files = $("#upload")[0].files;

    The return value from the `upload_init` endpoint will be a JSON
    payload with the information you sent, plus some additional
    elements:

    - id

        An MD5 hash key you will use later to access the status
        information for this file from the status payload.

    - size\_human

        A formatted human readable size you can use to display in a progress
        bar.

    - init\_time

        The time in seconds since the epoch of the intialization time. This
        value is currently not used.

    This API call will store the file list in a cache with a configurable
    expire time (if your caching implements expirations). If the web
    client does not upload the files before the expire time the cache will
    be emptied. Expiraration of cached elements is not done for you - your
    cache implementation must provide this capability.

    After calling the endpoint you can immediately call the status
    endpoint although the file upload process will not begin until your
    web client begins sending the files.

- 2. Initiate the upload for each file.

    You should upload each file separately using the `upload` endpoint,
    sending the file id returned in step 1. You can send the id in a
    custom header (X-Upload-Id) or as a query string parameter (but not as
    POST parameter).

    For example...

        $.each(files, function(i, file) {
          var data = new FormData();

          data.append("filename", file);
          
          $.ajax({
            url: "/upload",
            headers: { 'X-Upload-Id' : file_list[i].id },
            method: "POST",
            type: "POST",
            contentType: false,
            processData: false,
            cache: false,
            data: data,
            success: function(data) {
              ...
            },
            error: function(data)  {
              ...
            }
          });
        });

    The return value of the upload call will be a JSON payload similar to
    the payload returned for each file when you call the `upload_status` endpoint.

- 3. Monitor the upload progress.

    After successfully submitting all files for upload, you can begin
    monitoring the process by calling the `upload_status` endpoint. The
    return value is a JSON payload containing a hash where each element
    holds the status of one of the files you sent in the initialization
    phase. The keys of the hash are the MD5 hash identifier for the file.

    - filename
    - index

        The original index you associated with this file.

    - percent\_complete

        A value between 0 and 100 representing the percentage completion for
        that file.

    - elapsed\_time

        The number of microseconds that has elapsed since the start of the upload.

    - elapsed\_time\_formatted

        The number of seconds to 3 decimal places that has elapsed since the
        start of the upload.

        $.ajax({
          url: "/upload/status",
          success: function(data) {
            // display progress info for each file      
          }
        });

- 4. Optionally remove the upload status from the cache.

    Once all files have been uploaded successfully, call the
    `upload_reset` endpoint in order to clear the cache. If you do not
    clear the cache it will automatically (in the reference
    implementation) be cleared when the configured timeout period has
    elapsed.

    You may want to clear the cache immediately after successful
    uploads. If the user is fast enough and initiates another upload
    session, the previously cached information might be returned along
    with new cached data.

# METHODS AND SUBROUTINES

None of these methods should be called directly. They will be exposed
as URL endpoints when Apache is restarted.

## upload

Uploads a file to the webserver.

- endpoint: _/upload_
- method: POST

## upload\_config

Endpoint for retrieving the current configuration, an HTML form for
editing the configuration or for updating the configuration

- endpoint: _/upload/config_
- method: POST

    Saves the JSON payload representing configuration values to the
    configuration file. The values passed in the payload are _merged_
    with the existing configuration.  This means you do not have to pass
    all of the original configuration values in your payload if you only
    want to allow editing of a subset of those values.

    Return 200 and the entire configuration file as a JSON payload if
    successful. Similar to the GET method below, you can only save the
    configuration file if `is_configuration_editable()` returns a true
    value.

- method: GET

    Set the `Accept` header to `application/json` to return the
    configuration data, otherwise a form that allows you to edit the
    configuration data is presented.

    _Note that editing of configuration data is only available if the
    `is_configuration_editable()` method returns true._

    By default, that method will inspect the `allow_edit` variable in the
    gloabl section of the configuration.  You can override that method to
    provide your own method for determining whether configuration data can
    be edited.

    Returns a JSON payload with the configuration data or an HTML form.

    The form that is returned when the Accept headers do not include
    `application/json` can be defined as a [Template::Toolkit](https://metacpan.org/pod/Template%3A%3AToolkit) template
    in the configuration file.

## upload\_init

Initializes an upload session.

- endpoint: _/upload/init_
- method: POST

Accepts a JSON payload of files to be uploaded.  Returns the same list
with additional decorations.

See ["The Upload Steps"](#the-upload-steps)

## upload\_status

- endpoint: _/upload/status_
- method: GET

Returns a JSON payload with information on the progress of each file
being uploaded. See ["The Upload Steps"](#the-upload-steps)

## upload\_reset

Clears the cache for the current session.

- endpoint: _/upload/reset_
- method: GET

## upload\_version

Returns the version of the API.

- endpoint: _/upload/version_
- method: GET

## upload\_form

Endpoint to deliver a custom form for uploading files.

- endpoint: _/upload/form_
- method: GET

# OVERRIDING METHODS

The behavior of the uploader in your application can be controlled by
subclassing the `Apache2:Upload::Progress` and overriding certain methods.

## validate\_session(r, \[session-id\])

The `validate_session()` method is used to validate that the current
web user is authorized to upload files. Typically, a session cookie is
used to identify an authenticated (and authorized) user. You should
override this method to create your own authentication/authorization
scheme. If the user is authorized for uploading files, return a hash
containing the session identifier.  It will be used to store the
status of file uploads. Return undef if the user is either not
authenticated or not authorized to upload files.

You should also include a `prefix` member of the hash which will be
used as a prefix for uploaded files. The prefix should uniquely
identify your user so that files uploaded to your upload directory can
be associated with that specific user.

The reference implementation uses a cookie (`session_id`) to identify
the web user and allows uploads by default. It returns a hash with the
session identifier and an prefix of '1'.

See also ["Sessions"](#sessions).

## get\_session\_id

This method should return a unique id for a user's session. Typically
this might come from a cookie. The default implementation will return
the cookie value of the cookie that is specified in the `session`
section of the configuration.

## get\_upload\_id

This method should return the unique identifier assigned to one of the
files being uploaded. The default implementation will look in the
query string for the `upload_id` variable and look for a custom
header (`X-Upload-Id`).

## bake\_cookie

    bake_cookie(key, value, ...)

Helper routine for baking cookies.

Creates a string from key/value pairs. If the value is undefined then
the cookie attribute will not be of the form "key=value;" instead it
will be formatted as "key;".

## create\_cookie

The `create_cookie()` method is called to create a session cookie if
a cookie does not exist when delivering an upload formusing the `upload_form`
endpoint.

If you set the `no_cookie_error` value in the `session` section, the
endpoints will return an error code rather than trying to create a
cookie. The method is primarily for use by the reference
implementation.

# CREATING YOUR OWN CACHING MECHANISM

The reference implmentation for the upload progress meter uses a
[https://redis.io|Redis](https://redis.io|Redis) cache so that in a multi-server web
application, requests for upload status are served from a central
cache. You can create your own caching mechanism for a single server
environment or use some other cache repository like DynamoDB. The
class you specify in the Apache configuration in the
`<UploadProgress>` block need only implement a few methods
described below.

Methods will be passed one or all these values.

The [Apache2::ServerRec](https://metacpan.org/pod/Apache2%3A%3AServerRec) object.

- r

    The [Apache2::RequestRec](https://metacpan.org/pod/Apache2%3A%3ARequestRec) object.

- config

    The configuration object. This is an instance of
    [Class::Accessor::Fast](https://metacpan.org/pod/Class%3A%3AAccessor%3A%3AFast) which can be used to retrieve the top level
    configuration objects.

    Example:

        my $session_config = $config->get_session;

- session-id

    The session identifier, typically stored in a cookie.

- upload-id

    A unique id of the individual file being uploaded.

- id

    A compound key composed of the session and upload identifiers
    separated by a ':'.

- expire-time

    Number of seconds after which the entry should be expired.

## init\_session\_cache

    init_session_cache(s)

Perform whatever initialization ritual necessary for your
implementation. Return a true value to indication success.

## get\_session\_key, set\_session\_key

    get_session_key(r, id)
    set_session_key(r, id, value, expire-time )

An id is composed of the session identifier and the upload
identier. The method will be called to retrieve the serialized version
of the status object.  `value` will be a hash that you may need to
serialize before storing to your cache.

## get\_all\_session\_keys

    get_all_session_keys(r, session-id)

Should return an array containing all of the keys stored for the
specified session.

## get\_upload\_status

    get_upload_status(r, id)

Returns the object that was stored when the `set_session_key()`
method was called. This method is called when the web client access
the `/upload/status` endpoint.

## flush\_session\_cache

    flush_session_cache(r, session-id)

Perform whatever actions necessary to remove the session from the
cache. This is called when the web client access the `/upload/reset`
endpoint.

# APACHE CONFIGURATION

This is the basic configuration required to enable the progress meter.

    APREQ2_ReadLimit 2147483648
    
    PerlLoadModule Apache2::Upload::Progress

    PerlPostReadRequestHandler Apache2::Upload::Progress

    PerlPostConfigHandler Apache2::Upload::Progress::post_config
    
    <UploadProgress>
      UploadProgressHandler Apache2::Upload::Progress:Redis>
      UploadProgressConfig apache2-upload-progress.json>
    </UploadProgress>

Configuring Apache requires that you add the configuration directives
above. By default the maximum upload size is 64MB. Set
`APREQ2_ReadLimit` to a higher value if you want to allow larger file
uploads.

- `PerlLoadModule`, `PerlPostReadRequestHandler`, `PerlPostConfigHandler`

    These are required to enable the upload and progress monitoring. Just
    add them.

- `UploadProgress`

    This block will configure the handler that contains the status
    information as files are uploaded. You can create [your own progress
    caching mechanism](#creating-your-own-caching-mechanism) or use the
    reference implementation handler as shown above.

# REPOSITORY

[https://github.com/rlauer6/perl-upload-cgi.git](https://github.com/rlauer6/perl-upload-cgi.git)

# SEE ALSO

[Apache2::Request](https://metacpan.org/pod/Apache2%3A%3ARequest), [Apache2::Upload](https://metacpan.org/pod/Apache2%3A%3AUpload)

# AUTHOR

Rob Lauer - <rlauer6@comcast.net>

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 1930:

    Unterminated I<...> sequence

- Around line 2051:

    Expected '=item \*'

- Around line 2250:

    Unterminated C<...> sequence

- Around line 2678:

    '=item' outside of any '=over'
