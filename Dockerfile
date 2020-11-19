FROM registry.access.redhat.com/ubi8/ubi

LABEL name="ubi8-clamav" \
      vendor="Red Hat" \
      version="0.1.0" \
      release="1" \
      summary="UBI 8 ClamAV" \
      description="ClamAV for UBI 8" \
      maintainer="EPIC"

RUN yum -y update \
  && yum -y install yum-utils \
  && rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8 \
  && yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN yum install -y clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-devel clamav-lib clamav-server-systemd
RUN yum install -y wget

COPY config/clamd.conf /etc/clamd.conf
COPY config/freshclam.conf /etc/freshclam.conf

RUN mkdir /opt/app-root
RUN mkdir /opt/app-root/src
RUN chown -R 1001:0 /opt/app-root/src
RUN chmod -R ug+rwx /opt/app-root/src

# # To fix check permissions error for clamAV
RUN mkdir /var/log/clamav
RUN touch /var/log//clamav/clamav.log
RUN touch /var/log//clamav/freshclam.log
RUN chown -R 1001:0 /var/log/clamav
RUN chmod -R ug+rwx /var/log/clamav

RUN wget -t 5 -T 99999 -O /opt/app-root/src/main.cvd http://database.clamav.net/main.cvd && \
   wget -t 5 -T 99999 -O /opt/app-root/src/daily.cvd http://database.clamav.net/daily.cvd && \
   wget -t 5 -T 99999 -O /opt/app-root/src/bytecode.cvd http://database.clamav.net/bytecode.cvd && \
   chown clamupdate:clamupdate /opt/app-root/src/*.cvd

USER 1001

EXPOSE 3310

CMD clamd -c /etc/clamd.conf
