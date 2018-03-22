FROM kadamonkar/oracle-jdk-docker
MAINTAINER Onkar Kadam <onkar.kadam@outlook.com>


ENV RDECK_HTTP_PORT=4440 \
    RDECK_HTTPS_PORT=4443

EXPOSE 4440

# rundeck repo
COPY etc/yum.repos.d/rundeck.repo /etc/yum.repos.d/

RUN \
  yum clean all && \
  yum install -y --setopt=tsflags=nodocs \
    git \
    libffi-devel \
    gcc \
    gcc-c++ \
    cyrus-sasl-devel \
    saslwrapper \
    python-devel \
    openssl-devel \
    sshpass \
    createrepo \
    rundeck \
    rundeck-cli && \
  rm -rf /var/lib/rpm/__db* && \
  rpm --rebuilddb && \
  rm -rf /var/lib/yum/{history,repos,rpmdb-indexes,yumdb} && \
  rm -rf /var/log/yum.log /tmp/* /var/tmp/* && \
  yum clean all

RUN \
  curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py && \
  python /tmp/get-pip.py && \
  pip --no-cache-dir install --upgrade pip setuptools \
    -i https://pypi.python.org/simple

# rundeck conf
ADD etc/rundeck /etc/rundeck

ADD ssh /root/.ssh
ADD ssh /var/lib/rundeck/.ssh 

# rundeck sudoer conf
COPY etc/sudoers.d/rundeck /etc/sudoers.d/rundeck

RUN \
  chmod +x /etc/rundeck/run.sh && \
  chown -R rundeck:rundeck /var/lib/rundeck/.ssh /etc/rundeck && \
  chown -R root:root /root/.ssh && \
  wget https://github.com/rundeck-plugins/slack-incoming-webhook-plugin/releases/download/v1.0/slack-incoming-webhook-plugin-1.0.jar -P /var/lib/rundeck/libext/ && \
  chown rundeck:rundeck /var/lib/rundeck/libext/slack-incoming-webhook-plugin-1.0.jar

ENTRYPOINT ./etc/rundeck/run.sh
