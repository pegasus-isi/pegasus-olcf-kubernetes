FROM centos:centos7

#### ENV Variables For Packages ####
ENV PEGASUS_VERSION "$PEGASUS_VERSION"
ENV PEGASUS_VERSION_NUM "$PEGASUS_VERSION_NUM"
ENV BOSCO_VERSION_NUM "$BOSCO_VERSION_NUM"

#### ENV Variables For User and Group ####
ENV USER "$USER"
ENV USER_ID "$USER_ID"
ENV USER_GROUP "$USER_GROUP"
ENV USER_GROUP_ID "$USER_GROUP_ID"
ENV HOME "/home/${USER}"
ENV CCS_HOME "/ccs/home/${USER}"

#### Update Packages ####
RUN yum -y update

#### Install basic packages ####
RUN yum -y install which java-1.8.0-openjdk-devel sudo mysql-devel postgresql-devel epel-release vim python openssh-clients libgomp rsync perl perl-Data-Dumper

#### Add automation user ####
RUN groupadd -g ${USER_GROUP_ID} ${USER_GROUP} && \
    useradd -s /bin/bash -u ${USER_ID} -g ${USER_GROUP_ID} -m ${USER} && \
    mkdir -p $HOME/.ssh && chmod 700 $HOME/.ssh && chown ${USER}:${USER_GROUP} $HOME/.ssh

#### Install Pegasus from tarball ####
RUN curl -o /opt/${PEGASUS_VERSION}.tar.gz http://download.pegasus.isi.edu/pegasus/${PEGASUS_VERSION_NUM}/pegasus-binary-${PEGASUS_VERSION_NUM}-x86_64_rhel_7.tar.gz && \
    tar -xzvf /opt/${PEGASUS_VERSION}.tar.gz -C /opt && \
    rm /opt/${PEGASUS_VERSION}.tar.gz && \
    chown ${USER}:${USER_GROUP} -R /opt/${PEGASUS_VERSION}

ENV PATH "/opt/${PEGASUS_VERSION}/bin:$PATH"
ENV PYTHONPATH "/opt/${PEGASUS_VERSION}/lib/python2.7/dist-packages:$PYTHONPATH"
ENV PERL5LIB "/opt/${PEGASUS_VERSION}/lib/pegasus/perl:$PERL5LIB"

#### Install and configure BOSCO ####
RUN curl -o /opt/boscoinstaller.tar.gz ftp://ftp.cs.wisc.edu/condor/bosco/${BOSCO_VERSION_NUM}/boscoinstaller.tar.gz && \
    tar -xzvf /opt/boscoinstaller.tar.gz -C /opt && \
    /opt/boscoinstaller --prefix=/opt/bosco --owner=${USER} && \
    rm /opt/boscoinstaller && rm /opt/boscoinstaller.tar.gz && \
    chown ${USER}:${USER_GROUP} -R /opt/bosco

#### Copy Slurm cluster patch ####
COPY slurm_cluster_patch.tar.gz /opt

#### Comment out copy of key to authorized keys ####
RUN for lnum in {829..834}; do sed -i "${lnum}s/\(.*\)/#\1/" /opt/bosco/bin/bosco_cluster; done

#### Bosco SSH use socat for remote port forwarding ####
RUN sed -i "170s/.*/        SOCAT_BIN=\/ccs\/proj\/csc355\/dtn\/socat\/bin\/socat\n        ssh \$SSH_ARGS -o \"BatchMode yes\" \$REMOTE_USER\@\$REMOTE_HOSTNAME \/bin\/bash -l -c \"'echo Allocated port \$port for remote forward to 1>\&2 ; \$SOCAT_BIN TCP-LISTEN:\$port,fork TCP:\$GRIDMANAGER_ADDRESS > \/dev\/null 2>\&1 \& SOCAT_PID=\\\\\$! ; CONDOR_CONFIG=\$REMOTE_GLITE\/etc\/condor_config.ft-gahp \$REMOTE_GLITE\/bin\/condor_ft-gahp -f \$* ; kill \\\\\$SOCAT_PID'\"/" /opt/bosco/sbin/remote_gahp

#### Bosco Default Config ####
RUN mv /opt/bosco/local.* /opt/bosco/local && \
    sed -i "s/LOCAL_DIR.*/LOCAL_DIR = \/opt\/bosco\/local/" /opt/bosco/etc/condor_config && \
    sed -i "s/LOCAL_CONFIG_FILE.*/LOCAL_CONFIG_FILE = \/opt\/bosco\/local\/condor_config.local/" /opt/bosco/etc/condor_config && \
    echo "HOSTALLOW_WRITE=*" >> /opt/bosco/local/condor_config.local

#### Bosco Helper Script To Install Bosco on the DTNs ####
RUN echo "#!/bin/bash" > /opt/remote_bosco_setup.sh && \
    echo "rm ${HOME}/.bosco/.clusterlist" >> /opt/remote_bosco_setup.sh && \
    echo "bosco_cluster --add ${USER}@dtn.ccs.ornl.gov slurm" >> /opt/remote_bosco_setup.sh && \
    echo "/opt/${PEGASUS_VERSION}/bin/pegasus-configure-glite ${CCS_HOME}/bosco/glite" >> /opt/remote_bosco_setup.sh && \
    echo "tar -xzvf /opt/slurm_cluster_patch.tar.gz -C ${CCS_HOME}/bosco/glite" >> /opt/remote_bosco_setup.sh && \
    echo "sed -i \"s/\(^bsub_out.*\) < \(.*\)/\1 \2/\" ${CCS_HOME}/bosco/glite/bin/lsf_submit.sh" >> /opt/remote_bosco_setup.sh && \
    echo "sed -i \"s/supported_lrms=.*/supported_lrms=slurm,lsf/\" ${CCS_HOME}/bosco/glite/etc/batch_gahp.config" >> /opt/remote_bosco_setup.sh && \
    echo "sed -i \"s/lsf_nochecksubmission=.*/lsf_nochecksubmission=yes/\" ${CCS_HOME}/bosco/glite/etc/batch_gahp.config" >> /opt/remote_bosco_setup.sh && \
    echo "sed -i \"s/lsf_nologaccess=.*/lsf_nologaccess=yes/\" ${CCS_HOME}/bosco/glite/etc/batch_gahp.config" >> /opt/remote_bosco_setup.sh && \
    chown ${USER}:${USER_GROUP} /opt/remote_bosco_setup.sh && chmod +x /opt/remote_bosco_setup.sh

RUN echo "#!/bin/bash" > /opt/entrypoint.sh && \
    echo "ln -s /var/secrets/ssh/id_rsa ${HOME}/.ssh/bosco_key.rsa" >> /opt/entrypoint.sh && \
    echo "ln -s /var/secrets/ssh/id_rsa.pub ${HOME}/.ssh/bosco_key.rsa.pub" >> /opt/entrypoint.sh && \
    echo "ln -s /var/secrets/ssh/id_rsa-cert.pub ${HOME}/.ssh/bosco_key.rsa-cert.pub" >> /opt/entrypoint.sh && \
    echo "ln -s /var/secrets/ssh/known_hosts ${HOME}/.ssh/known_hosts" >> /opt/entrypoint.sh && \
    echo "sed -i \"s/CONDOR_HOST.*/CONDOR_HOST = \$HOSTNAME/\" /opt/bosco/etc/condor_config" >> /opt/entrypoint.sh && \
    echo "sed -i \"s/COLLECTOR_NAME.*/COLLECTOR_NAME = Personal Condor at \$HOSTNAME/\" /opt/bosco/etc/condor_config" >> /opt/entrypoint.sh && \
    echo -e "if [ -n \"\$GRIDMANAGER_SERVICE_ADDRESS\" ]; then\n    sed -i \"160s/.*/    GRIDMANAGER_ADDRESS=\\\"\$GRIDMANAGER_SERVICE_ADDRESS\\\"/\" /opt/bosco/sbin/remote_gahp\nfi" >> /opt/entrypoint.sh && \
    echo "source /opt/bosco/bosco_setenv" >> /opt/entrypoint.sh && \
    echo "bosco_start" >> /opt/entrypoint.sh && \
    echo "while true; do sleep 60; done" >> /opt/entrypoint.sh && \
    chown ${USER}:${USER_GROUP} /opt/entrypoint.sh && chmod +x /opt/entrypoint.sh

USER ${USER}
RUN echo "source /opt/bosco/bosco_setenv" >> ${HOME}/.bashrc

ENTRYPOINT [ "/opt/entrypoint.sh" ]
