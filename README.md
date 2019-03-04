# Running Pegasus and Condor on OLCF Kubernetes

This project prepares a container that can run on OLCF's Kubernetes infrastructure and provides yaml pod specification templates, that can be used to spawn pods that mount Titan's Lustre filesystem and provide access to Titan's batch scheduler.

## Basic scripts and files

_Docker/Dockerfile_. Dockerfile used to prepare a container with Pegasus and Condor, ommiting Pegasus' R support

_Specs/pegasus-submit.yml_. Contains Kubernetes pod specification that can be used to spawn a pegasus/condor pod that has access to Titan's Lustre filesystem and its batch scheduler.

## Prerequisites

- Openshift's origin client https://github.com/openshift/origin/releases
- A working RSA Token to access OLCF's systems
- An automation user for OLCF's systems
- Allocation on OLCF's Kubernetes Cluster

Step 1: Login to OLCF's Kubernetes
-----------------------------------
```
oc login -u YOUR_USERNAME https://marble.ccs.ornl.gov/
```

Step 2a: Create a new build and build the image
------------------------------------------------
```
oc new-build --name=pegasus-olcf -D - < Docker/Dockerfile
```

or

Step 2b: Start a new build in case the Dockerfile has been updated
-------------------------------------------------------------------
```
oc start-build pegasus-olcf --from-file=Docker/Dockerfile
```

Step 3: Start a Kubernetes pod with Titan access
--------------------------------------------------
```
oc create -f Specs/pegasus-submit.yml
```

Step 4: Get an interactive shell
--------------------------------------------------
```
oc rsh pegasus-submit
```

Step 5: Start HTCondor
--------------------------------------------------
```
condor_master #Execute this in the interactive shell
```

Step 6: Change to your designated HOME Dir
--------------------------------------------------
```
cd $HOME #Execute this in the interactive shell
```
