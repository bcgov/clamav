![Image of ClamAV](https://www.clamav.net/assets/clamav-trademark.png)
# ClamAV [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE) [![Lifecycle:Stable](https://img.shields.io/badge/Lifecycle-Stable-97ca00)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)

ClamAV® is an open source antivirus engine for detecting trojans, viruses, malware & other malicious threats.

This is a repo setup for utilization in Red Hat Openshift.  This solution allows you to create a pod in your openshift environment to scan any file for known virus signatures, quickly and effectively.

The builds package the barebones service, and the deployment config will download latest signatures on first run.

Freshclam can be run within the container at any time to update the existing signatures.  Alternatively, you can re-deploy which will fetch the latest into the running container.

# Deployment

The templates in the [openshift/templates](./openshift/templates) will build and deploy the app.  Modify to suit your own environment.  [openshift/templates/clamav-bc.conf](./openshift/templates/clamav-bc.conf) will create your builder image (ideally in your tools project), and [openshift/templates/clamav-dc.conf](./openshift/templates/clamav-dc.conf) will create the pod deployment.  Modify the environment variables defined in both the build config and deployment config appropriately.

## Deploy with Helm

The Helm chart deploys a standard StatefulSet. This deployment should work on [OpenShift Local](https://github.com/crc-org/crc), [kind](https://kind.sigs.k8s.io/) or even [Docker Desktop](https://docs.docker.com/desktop/kubernetes/)

## OpenShift or OpenShift Local

1. Optional: if running on openshift local, create a namespace
```
oc new-project clamav-demo
```
2. Import the build config template and create the build config

```
oc apply -f openshift/clamav-bc.conf -n clamav-demo
oc new-app --template=clamav
```

3. Start a build
```
oc start-build clamav-build
```

4. When the build is complete, new image stream tag should be avilable, `clamav` with a single image stream tag `clamav:latest`

5. Deploy, if running locally be sure to set the clamav.freshclam.mirrors

```
cd charts
helm install clamav clamav --set clamav.image=image-registry.openshift-image-registry.svc:5000/clamav-demo/clamav --set clamav.freshclam.mirrors=https://db.us.clamav.net
```

### Kind

Below are the steps required to deploy to [kind](https://kind.sigs.k8s.io/). When the container starts up it will need to pull
the latest virus defintions. It can take a little while before the pods are ready.

```
docker build -f Dockerfile . -t clamav:latest

kind create cluster
kind load docker-image clamav:latest
cd charts
helm install clamav clamav --set clamav.image=docker.io/library/clamav --set clamav.imagePullPolicy=Never
```

The commands are:

1. Build the docker image, tagging it as latest
2. Create a [kind](https://kind.sigs.k8s.io/) cluster
3. Load the build image into the cluster node(s)
3. Chages into the charts subdirectory
4. Install the helm chart changing the docker image to the loaded image and changing the pull policy so it uses the loaded image.

To clean up everything,

```
docker rmi clamav:latest
kind delete cluster
```

## Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an [issue](../../issues).
