#!/usr/bin/env bash

#### ENV Variables For Packages ####
PEGASUS_VERSION="pegasus-4.9.3dev"
PEGASUS_VERSION_NUM="4.9.3dev"
BOSCO_VERSION_NUM="1.2.12"

#### ENV Variables For User and Group ####
USER=""
USER_ID=""
USER_GROUP=""
USER_GROUP_ID=""
GRIDMANAGER_SERVICE_PORT=""
GRIDMANAGER_SERVICE_ADDRESS="${USER_GROUP}.marble.ccs.ornl.gov:${GRIDMANAGER_SERVICE_PORT}"


#### Don't edit this part ####

sed -e "s/\"\$USER_GROUP\"/\"${USER_GROUP}\"/" \
    templates/Specs/pegasus-submit-build.yml > Specs/pegasus-submit-build.yml

sed -e "s/\"\$PEGASUS_VERSION\"/\"${PEGASUS_VERSION}\"/" \
    -e "s/\"\$PEGASUS_VERSION_NUM\"/\"${PEGASUS_VERSION_NUM}\"/" \
    -e "s/\"\$BOSCO_VERSION_NUM\"/\"${BOSCO_VERSION_NUM}\"/" \
    -e "s/\"\$USER\"/\"${USER}\"/" \
    -e "s/\"\$USER_ID\"/\"${USER_ID}\"/" \
    -e "s/\"\$USER_GROUP\"/\"${USER_GROUP}\"/" \
    -e "s/\"\$USER_GROUP_ID\"/\"${USER_GROUP_ID}\"/" \
    templates/Docker/Dockerfile > Docker/Dockerfile

sed -e "s/\$GRIDMANAGER_SERVICE_PORT/${GRIDMANAGER_SERVICE_PORT}/" \
    templates/Specs/pegasus-submit-service.yml > Specs/pegasus-submit-service.yml

sed -e "s/\/\$USER_GROUP\//\/${USER_GROUP}\//" \
    -e "s/\"\$GRIDMANAGER_SERVICE_ADDRESS\"/\"${GRIDMANAGER_SERVICE_ADDRESS}\"/" \
    templates/Specs/pegasus-submit-pod.yml > Specs/pegasus-submit-pod.yml

##############################
