FROM amazonlinux:2

# ADD perl-aws.repo /etc/yum.repos.d/perl-aws.repo
RUN amazon-linux-extras install epel -y

RUN yum install -y perl-core

RUN yum install -y less tree gcc make procps curl \
    iputils net-tools tar automake autoconf \
    openssl openssl-devel expat expat-devel

# Apache
RUN yum install -y httpd mod_perl 'perl(Apache2::Request)'

# cpanm
RUN curl -L https://cpanmin.us | perl - App::cpanminus

# cleanup 
RUN yum clean all && rm -rf /var/cache/yum

RUN mkdir -p /var/www/{log,html,spool}

CMD /usr/sbin/apachectl -D FOREGROUND
