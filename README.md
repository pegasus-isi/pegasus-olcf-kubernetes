# Running Pegasus and HTCondor on OLCF Kubernetes [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3825253.svg)](https://doi.org/10.5281/zenodo.3825253)

This project prepares a container that can run on OLCF's Kubernetes infrastructure and provides yaml pod specification templates, that can be used to spawn pods that mount OLCF's GPFS filesystem and provide access to the batch schedulers of Summit, RHEA and the DTN.

<img src="docs/images/pegasus-kubernetes-deployment.png?raw=true">

## Basic scripts and files

_bootstrap.sh_. This script generates the personalized Dockerfile and Kubernetes pod and service specifications for your deployment. It updates the template files with your automation user acount details, and saves them under the Docker and the Specs folders.

_Docker/Dockerfile_. Dockerfile used to prepare a container with Pegasus and Condor, ommiting Pegasus' R support.

_Specs/pegasus-submit-build.yml_. Contains Kubernetes build specifications for the pegasus-olcf image.

_Specs/pegasus-submit-service.yml_. Contains Kubernetes service specification that can be used to spawn a Nodeport service that exposes the HTCondor Gridmanager Service running in your submit pod, to outside world.

_Specs/pegasus-submit-pod.yml_. Contains Kubernetes pod specification that can be used to spawn a pegasus/condor pod that has access to Summits's GPFS filesystem and its batch scheduler.

## Prerequisites

- Openshift's origin client https://github.com/openshift/origin/releases
- A working RSA Token to access OLCF's systems
- An automation user for OLCF's systems
- Allocation on OLCF's Kubernetes Cluster

Step 1a: Update bootstrap.sh
-----------------------------
In bootstrap.sh update the section "ENV Variables For User and Group" with your automation user's name, id, group name, group id and the Gridmanager Service Port, which must be in the range 30000-32767.

More specifically replace:
- _USER_, with the username of your automation user (eg. csc001\_auser)
- _USER\_ID_, with the user id of your automation user (eg. 20001)
- _USER\_GROUP_, with the project name your automation user belongs to (eg. csc001)
- _USER\_GROUP\_ID_, with the project group id your automation user belongs to (eg. 10001)
- _GRIDMANAGER\_SERVICE\_PORT_, with the Kubernetes Nodeport port number the Gridmanager Service should use (eg. 32752)

Step 1b: Run bootstrap.sh
--------------------------
Generate the Dockerfile and the Spec files for your deployment.
```
bash bootstrap.sh
```

Step 2: Login to OLCF's Kubernetes
-----------------------------------
```
oc login -u YOUR_USERNAME https://marble.ccs.ornl.gov/
```

Step 3a: Create a new build build configuration 
------------------------------------------------
```
oc create -f Specs/pegasus-submit-build.yml
```

Step 3b: Start a new build with your updated Dockerfile
--------------------------------------------------------
```
oc start-build pegasus-olcf --from-file=Docker/Dockerfile
```

You can trace the log of the build by running:

```
oc logs -f build/pegasus-olcf-1
```

Step 4: Start a Kubernetes Service that will expose your pod services
----------------------------------------------------------------------
```
oc create -f Specs/pegasus-submit-service.yml
```

Step 5: Start a Kubernetes pod with batch job submission capabilities
----------------------------------------------------------------------
```
oc create -f Specs/pegasus-submit-pod.yml
```

Step 6: Get an interactive shell
--------------------------------------------------
```
oc exec -it pegasus-submit /bin/bash
```

Step 7: Change to your designated HOME DIR
--------------------------------------------------
```
cd $HOME #Execute this in the interactive shell
```

Step 8: Configuring for batch submissions
--------------------------------------------------
If this is the first time you are using the service, configure the batch submissions by running the following command.
```
bash /opt/remote_bosco_setup.sh #Execute this in the interactive shell
```

Deleting the pod and the service
--------------------------------------------------
In order to delete the pod, exit the interactive shell by typing "exit"
and then use the following command.

```
oc delete pod pegasus-submit
```

To delete the service use:

```
oc delete svc pegasus-submit-service
```
