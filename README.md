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

Step 1: Update Docker/Dockerfile
---------------------------------
In Docker/Dockerfile update the section "Add automation user" with your automation user's group id, group name, user id, user name and $HOME location.

More specifically replace:
- _AUTOMATION\_USER\_GROUP\_ID_, with the group id your automation user belongs to (eg. 10001)
- _AUTOMATION\_USER\_GROUP\_NAME_, with the group name your automation user belongs to (eg. csc001)
- _AUTOMATION\_USER\_ID_, with the user id of your automation user (eg. 20001)
- _AUTOMATION\_USER\_NAME_, with the username of your automation user (eg. csc001\_auser)
- _AUTOMATION\_USER\_HOME\_DIR_, with the home folder of your automation user. This folder should point to
a location on the Lustre filesytem (eg. /lustre/atlas/scratch/csc001_auser/csc001)

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

Step 4: Start a Kubernetes pod with Titan access
--------------------------------------------------
```
oc create -f Specs/pegasus-submit.yml
```

Step 5: Get an interactive shell
--------------------------------------------------
```
oc rsh pegasus-submit
```

Step 6: Start HTCondor
--------------------------------------------------
```
condor_master #Execute this in the interactive shell
```

Step 7: Change to your designated HOME DIR
--------------------------------------------------
```
cd $HOME #Execute this in the interactive shell
```
