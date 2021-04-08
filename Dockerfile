FROM openshift/base-centos7


RUN yum -y install epel-release
RUN yum -y update
RUN yum clean all
RUN yum install -y clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-devel clamav-lib clamav-server-systemd

COPY config/clamd.conf /etc/clamd.conf
COPY config/freshclam.conf /etc/freshclam.conf

RUN chown -R 1001:0 /opt/app-root/src
RUN chmod -R ug+rwx /opt/app-root/src
RUN chown -R 1001:0 /opt/app-root/src

USER 1001

EXPOSE 3310

CMD freshclam && clamd -c /etc/clamd.conf
