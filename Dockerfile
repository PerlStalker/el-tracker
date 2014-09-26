FROM ubuntu
MAINTAINER Randall Smith <perlstalker@gmail.com>

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y perl cpanminus build-essential
RUN apt-get install -y libmoose-perl libdatetime-format-iso8601-perl libdatetime-format-natural-perl libio-interactive-perl libfile-homedir-perl
RUN apt-get install -y libdbi-perl libdbix-class-perl libdbd-sqlite3-perl sqlite3

RUN cpanm MooseX::App WWW::Mechanize

ADD bin/ /usr/local/bin/
ADD lib/ /usr/local/lib/

VOLUME /data

env DEFAULTS --config /data/config.yaml --dsn dbi:SQLite:dbname=/data/el-tracker.sqlite3

ENTRYPOINT ["/usr/local/bin/run.sh" ]
# default to this month's report
#CMD ["report", "--start", "`date \"+%Y-%m-01\"`", "--stop",  "`date --date=\"+1 month\" \"+%Y-%m-01\"`" ]
CMD ["help"]
