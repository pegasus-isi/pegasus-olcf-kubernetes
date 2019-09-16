# Running Pegasus and Condor on OLCF Kubernetes

This project prepares a container that can run on OLCF's Kubernetes infrastructure and provides yaml pod specification templates, that can be used to spawn pods that mount OLCF's GPFS filesystem and provide access to the batch schedulers of Summit, RHEA and the DTN.

## Basic scripts and files

_Docker/Dockerfile_. Dockerfile used to prepare a container with Pegasus and Condor, ommiting Pegasus' R support

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
- _USER\_GROUP_, with the group name your automation user belongs to (eg. csc001)
- _USER\_GROUP\_ID_, with the group id your automation user belongs to (eg. 10001)
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

Step 3a: Create a new build and build the image
------------------------------------------------
```
oc new-build --name=pegasus-olcf -D - < Docker/Dockerfile
```

You can trace the log of the build by running:

```
oc logs -f build/pegasus-olcf-1
```

Step 3b: Start a new build in case the Dockerfile has been updated
-------------------------------------------------------------------
```
oc start-build pegasus-olcf --from-file=Docker/Dockerfile
```

Step 4: Start a Kubernetes Service that will expose your pod services
----------------------------------------------------------------------
```
oc create -f Specs/pegasus-submit-service.yml
```

Step 5: Start a Kubernetes pod with batch job submission capabilities
----------------------------------------------------------------------
```
oc create -f Specs/pegasus-submit.yml
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
/opt/remote_bosco_setup #Execute this in the interactive shell
```

Deleting the pod
--------------------------------------------------

In order to delete the pod, exit the interactive shell by typing "exit"
and then use the following command.

```
oc delete pod pegasus-submit
```
