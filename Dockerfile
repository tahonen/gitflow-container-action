FROM centos:latest as build

ENV PYTHON=/usr/libexec/platform-python3.6 \
    PATH=$PATH:/usr/libexec/platform-python3.6

    
LABEL io.k8s.description="Container for building (lint and guld) client from source" \
      io.k8s.display-name="Client Builder" \
      maintainer="Tero Ahonen <tero@gamerefinery.com>"

ARG ENVIRONMENT=dev

# install nodejs
USER root

RUN curl -sL https://rpm.nodesource.com/setup_10.x | bash - && \
    yum -y install nodejs git && \ 
    npm install -g yarn && \
    yum update -y && \
    yum clean all -y --enablerepo='*' && \
    touch .env


COPY index.html /builds/${ENVIRONMENT}/

# create runtime
FROM registry.access.redhat.com/ubi8/nginx-118

USER 0
COPY --from=build /builds/${ENVIRONMENT} /tmp/src/
RUN ls -la && chown -R 1001:0 /tmp/src
USER 1001

RUN /usr/libexec/s2i/assemble

CMD /usr/libexec/s2i/run