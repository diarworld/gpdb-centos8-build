FROM centos:centos8

# Install some basic utilities and build tools
RUN yum makecache && \
    rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official && \
    yum -y install dnf-plugins-core && \
    yum config-manager --set-enabled PowerTools && \
    yum -y install epel-release java-1.8.0-openjdk-devel && \
    yum -y install git iproute net-tools openssh-server rsync sudo time vim wget unzip && \
    yum -y install autoconf bison cmake3 flex gperf indent jq libtool make && \
    yum clean all

# install all software we need
RUN yum makecache && \
    yum -y install python2-pip && \
    yum -y install python2-devel python2-setuptools && \
    yum -y install apr-devel bzip2-devel expat-devel libcurl-devel && \
    yum -y install libevent-devel libuuid-devel libxml2-devel libyaml-devel libzstd-devel && \
    yum -y install openssl-devel pam-devel readline-devel snappy-devel && \
    yum -y install libicu perl-ExtUtils-Embed perl-Env perl-JSON && \
    pip2 install psi psutil lockfile && \
    yum clean all

# setup ssh configuration
# RUN ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa && \
#     cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && \
#     chmod 0600 /root/.ssh/authorized_keys && \
#     echo -e "password\npassword" | passwd 2> /dev/null && \
#     { ssh-keyscan localhost; ssh-keyscan 0.0.0.0; } >> /root/.ssh/known_hosts && \
#     #
#     ssh-keygen -f /etc/ssh/ssh_host_key -N '' -t rsa1 && \
#     ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa && \
#     ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa && \
#     sed -i -e 's|Defaults    requiretty|#Defaults    requiretty|' /etc/sudoers && \
#     sed -ri 's/UsePAM yes/UsePAM no/g;s/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
#     sed -ri 's@^HostKey /etc/ssh/ssh_host_ecdsa_key$@#&@;s@^HostKey /etc/ssh/ssh_host_ed25519_key$@#&@' /etc/ssh/sshd_config

# install gcc 8.2.1-3.5.el8 and build and run environment for gpdb
RUN yum -y install gcc gcc-c++ patch openldap-devel rpmdevtools apr-util apr-util-devel && yum clean all && \
    echo -e '#!/bin/sh' >> /etc/profile.d/jdk_home.sh && \
    echo -e 'export JAVA_HOME=/etc/alternatives/java_sdk' >> /etc/profile.d/jdk_home.sh && \
    echo -e 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile.d/jdk_home.sh

# setup curl and maven
RUN yum install -y curl maven && \
    alternatives --set python /usr/bin/python2 && \
    yum clean all

# create user gpadmin since GPDB cannot run under root
# RUN groupadd -g 1000 gpadmin && useradd -u 1000 -g 1000 gpadmin && \
#     echo "gpadmin  ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/gpadmin && \
#     groupadd supergroup && usermod -a -G supergroup gpadmin && \
#     #
#     mkdir /home/gpadmin/.ssh && \
#     ssh-keygen -t rsa -N "" -f /home/gpadmin/.ssh/id_rsa && \
#     cat /home/gpadmin/.ssh/id_rsa.pub >> /home/gpadmin/.ssh/authorized_keys && \
#     chmod 0600 /home/gpadmin/.ssh/authorized_keys && \
#     echo -e "password\npassword" | passwd gpadmin 2> /dev/null && \
#     { ssh-keyscan localhost; ssh-keyscan 0.0.0.0; } >> /home/gpadmin/.ssh/known_hosts && \
#     chown -R gpadmin:gpadmin /home/gpadmin/.ssh
