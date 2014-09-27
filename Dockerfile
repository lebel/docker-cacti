FROM lebel/centos7:latest
MAINTAINER David Lebel <lebel@lebel.org>
# forked from https://github.com/pozgo/docker-cacti  !Thanks!
# must be run with --link=yourdbcontainer:mysql and
#             with --volumes-from=mydatacontainer or
#                  -v myrra:/var/lib/cacti/rra -v /var/log/cacti

# I'm using a prepopulated cacti database on tutum/mariadb with 
# user named "cactiuser" with password "password.
# Eventually I intend to detect if the database is empty, properly 
# populate it with -e environment variables for admin user, 
# cacti user, etc... This is a WIP.

ADD install/ /data/install 
ADD config/ /data/config

VOLUME /var/lib/cacti/rra
VOLUME /var/log/cacti

RUN yum update -y && yum install -y --nogpgcheck cacti openssh-clients 

# since spine isn't in epel, we'll build it manually
RUN cd /data/install && \
./spine.sh && \
mv /data/config/info.php /var/www/html/info.php && \
mv /data/config/db.php /etc/cacti/db.php && \
mv /data/config/cacti.conf /etc/httpd/conf.d/cacti.conf && \
mv /data/config/spine.conf /usr/local/spine/etc/spine.conf && \
cd /data/install/ && \
rm -rf /data/install/cacti-spine-0.8.8b

RUN cd /data/install && ./cron.sh 

RUN ln -sf /usr/share/zoneinfo/Canada/Eastern /etc/localtime && \
echo "date.timezone = Canada/Eastern" >> /etc/php.ini 

ADD container-files /

EXPOSE 80
