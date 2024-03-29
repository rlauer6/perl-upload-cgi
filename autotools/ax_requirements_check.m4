AC_DEFUN([AX_REQUIREMENTS_CHECK],[
  ads_PERL_MODULE([Amazon::Credentials], [], [1.1.16])
  ads_PERL_MODULE([Amazon::S3], [], [0.59])
  ads_PERL_MODULE([Carp::Always], [], [])
  ads_PERL_MODULE([Class::Accessor::Fast], [], [0.51])
  ads_PERL_MODULE([Config::IniFiles], [], [3.000003])
  ads_PERL_MODULE([Data::UUID], [], [1.226])
  ads_PERL_MODULE([Date::Format], [], [2.24])
  ads_PERL_MODULE([File::HomeDir], [], [1.006])
  ads_PERL_MODULE([JSON], [], [4.07])
  ads_PERL_MODULE([Linux::Inotify2], [], [2.3])
  ads_PERL_MODULE([Workflow::Inotify], [], [1.0.3])
  ads_PERL_MODULE([Log::Log4perl], [], [1.55])
  ads_PERL_MODULE([Log::Log4perl::Level], [], [])
  ads_PERL_MODULE([Number::Bytes::Human], [], [0.11])
  ads_PERL_MODULE([Readonly], [], [2.05])
  ads_PERL_MODULE([Redis], [], [1.999])
  ads_PERL_MODULE([Template], [], [3.100])
])
