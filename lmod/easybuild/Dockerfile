FROM quay.io/guimou/easybuild-ubi8-py39 AS builder

USER root
RUN chown -R easybuild:easybuild /opt/apps/easybuild
USER easybuild

RUN /opt/app-root/src/easybuild_install.sh
# RUN source /opt/apps/lmod/lmod/init/bash

WORKDIR /opt/apps/easybuild/repos
RUN git clone https://github.com/easybuilders/easybuild-easyconfigs
# RUN sed -i '\!^robot-paths! s!$!:/opt/apps/easybuild/repos/easybuild-easyconfigs/!' /opt/apps/easybuild/easybuild.d/config.cfg

# USER easybuild

WORKDIR /opt/apps/easybuild
# FSL 6.0.1
RUN eb repos/easybuild-easyconfigs/easybuild/easyconfigs/f/FSL/FSL-6.0.1* --download-timeout=1000 -r
# FreeSurfer 7.1.1
RUN eb repos/easybuild-easyconfigs/easybuild/easyconfigs/f/FreeSurfer/FreeSurfer-7.1.1-centos* --download-timeout=1000 -r



FROM registry.access.redhat.com/ubi8/s2i-core:1 AS runner

USER 1001

# load from local easybuild-data folder
# COPY --chown=1001:0 easybuild-data/. /opt/app-root/src/easybuild-data/

# Load from multistage docker build
COPY --from=builder --chown=1001:0 /opt/apps/easybuild/ /opt/app-root/src/easybuild-data/

COPY copy_data.sh /opt/app-root/src/copy_data.sh
