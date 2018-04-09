FROM openshift/origin:latest

# Reset the entrypoint
ENTRYPOINT ["/bin/sh", "-c"]

RUN yum install -y clamav-server clamav-scanner clamav-data --disablerepo=origin-local-release 

