FROM openshift/ccs-qsub:latest

#### Change to user 0 ####
USER 0

#### Update Packages ####
RUN yum -y update

#### Install basic packages ####
RUN yum -y install which java-1.8.0-openjdk-devel sudo mysql-devel postgresql-devel epel-release vim python

#### Install HTCondor from repo ####
RUN curl -o /etc/yum.repos.d/condor.repo http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-previous-rhel7.repo
RUN rpm --import http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor 
RUN yum -y install condor-all
RUN chmod -R o+w /var/{lib,log,lock,run}/condor

#### Configure HTCondor ####
RUN echo "DAEMON_LIST = MASTER, SCHEDD, COLLECTOR" >> /etc/condor/config.d/50-main.config
RUN echo "TRUST_UID_DOMAIN = TRUE" >> /etc/condor/config.d/50-main.config
RUN echo "ALLOW_WRITE = *" >> /etc/condor/config.d/50-main.config

#### Install Pegasus from repo ####
RUN curl -o /etc/yum.repos.d/pegasus.repo http://download.pegasus.isi.edu/wms/download/rhel/7/pegasus.repo
RUN yum -y install pegasus
RUN pegasus-configure-glite

#### Remove quotes from project name ####
RUN sed -i 's/echo "#PBS -A ${PROJECT}"/value=`strip_quotes $PROJECT`\n    echo "#PBS -A ${value}"/' $(condor_config_val GLITE_LOCATION)/bin/pbs_local_submit_attributes.sh

#### Monitor corrent queue on titan ####
RUN sed -i '236s/.*/        child_stdout = os.popen("%s -f %s" % (qstat, jobid+"@titan-batch")) # -1 conflicts with -f in PBS Pro/' $(condor_config_val GLITE_LOCATION)/bin/pbs_status.py

RUN sed -i '238s/.*/        child_stdout = os.popen("%s -f -1 %s" % (qstat, jobid+"@titan-batch"))/' $(condor_config_val GLITE_LOCATION)/bin/pbs_status.py

#### Update nsswitch to read /etc/hosts file #### 
RUN echo "hosts:  files dns" >> /etc/nsswitch.conf

#### Add moab bin to PATH ####
ENV PATH "/opt/moab/bin/:$PATH"

#### Add automation user ####
RUN groupadd -g AUTOMATION_USER_GROUP_ID AUTOMATION_USER_GROUP_NAME
RUN useradd -s /bin/bash -u AUTOMATION_USER_ID -g AUTOMATION_USER_GROUP_ID -M AUTOMATION_USER_NAME

ENV HOME AUTOMATION_USER_HOME_DIR
