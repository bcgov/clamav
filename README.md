# clamav
Clamav service for openshift.

This repository is for running a clamav service within an openshift project.  The builds package the barebones service, and the deployment config will download latest signatures on first run.

Freshclam can be run within the container at any time to update the existing signatures.  Alternatively, you can re-deploy which will fetch the latest into the running container.