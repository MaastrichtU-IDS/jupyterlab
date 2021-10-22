# FROM quay.io/guimou/easybuild-data:py39-full_latest AS init
# Multi stages builder:
# 1. init to reuse odh-highlander easybuild-data
# 2. builder to install new modules with easybuild container
# 3. runner to copy the new modules to the easybuild-data docker image that will run


FROM quay.io/guimou/easybuild-ubi8-py39 AS builder

ENV LMOD_ROOT=/opt/apps/lmod
ENV LMOD_PKG=/opt/apps/lmod/lmod
ENV LMOD_DIR=$LMOD_PKG/libexec
ENV LMOD_CMD=$LMOD_PKG/libexec/lmod
ENV MODULESHOME=$LMOD_PKG

USER root
RUN /opt/app-root/src/easybuild_install.sh

# COPY --from=init --chown=easybuild:0 /opt/apps/easybuild /opt/apps/easybuild

COPY --from=quay.io/guimou/easybuild-data:py39-full_latest --chown=easybuild:0 /opt/app-root/src/easybuild-data /opt/apps/easybuild

# WORKDIR /opt/apps/easybuild/repos
# RUN git clone https://github.com/easybuilders/easybuild-easyconfigs
# RUN sed -i '\!^robot-paths! s!$!:/opt/apps/easybuild/repos/easybuild-easyconfigs/!' /opt/apps/easybuild/easybuild.d/config.cfg

# RUN chown -R easybuild:0 /opt/apps/easybuild

USER easybuild
WORKDIR /opt/apps/easybuild

# ENTRYPOINT [ "bash" ]
COPY install_modules.sh /tmp/install_modules.sh

RUN /tmp/install_modules.sh
# RUN rm /tmp/install_modules.sh



## Copy all data in the final easybuild-data image
FROM registry.access.redhat.com/ubi8/s2i-core:1 AS runner

USER 1001

# load from local easybuild-data folder
# COPY --chown=1001:0 easybuild-data/. /opt/app-root/src/easybuild-data/

# Load from multistage docker build
COPY --from=builder --chown=1001:0 /opt/apps/easybuild/ /opt/app-root/src/easybuild-data/

COPY copy_data.sh /opt/app-root/src/copy_data.sh
