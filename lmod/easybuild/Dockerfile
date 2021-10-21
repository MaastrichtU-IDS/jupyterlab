FROM quay.io/guimou/easybuild-ubi8-py39 AS builder

ENV LMOD_ROOT=/opt/apps/lmod
ENV LMOD_PKG=/opt/apps/lmod/lmod
ENV LMOD_DIR=$LMOD_PKG/libexec
ENV LMOD_CMD=$LMOD_PKG/libexec/lmod
ENV MODULESHOME=$LMOD_PKG

USER root
RUN /opt/app-root/src/easybuild_install.sh

WORKDIR /opt/apps/easybuild/repos
RUN git clone https://github.com/easybuilders/easybuild-easyconfigs
# RUN sed -i '\!^robot-paths! s!$!:/opt/apps/easybuild/repos/easybuild-easyconfigs/!' /opt/apps/easybuild/easybuild.d/config.cfg

RUN chown -R easybuild:0 /opt/apps/easybuild
USER easybuild
WORKDIR /opt/apps/easybuild

# ENTRYPOINT [ "bash" ]

# Install GCC
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/g/GCC/GCC-1*
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/g/GCC/GCC-9*
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/g/GCC/GCC-8*

# Install Python 2.7, 3.7, 3.8, 3.9
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/p/Python/Python-2.7.18-GCCcore-10.2.0*
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/p/Python/Python-3.6.6*
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/p/Python/Python-3.7*
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/p/Python/Python-3.8*
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/p/Python/Python-3.9*

# Install Java
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/j/Java/Java-1.8.eb
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/j/Java/Java-1.9*
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/j/Java/Java-11*
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/j/Java/Java-13*
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/j/Java/Java-16*

# Install FSL 6.0.3
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/f/FSL/FSL-6.0.3* --download-timeout=1000
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/f/FSL/FSL-6.0.2* --download-timeout=1000
RUN eb -r repos/easybuild-easyconfigs/easybuild/easyconfigs/f/FSLeyes/FSLeyes-*
# Install FreeSurfer 7.1.1
RUN eb repos/easybuild-easyconfigs/easybuild/easyconfigs/f/FreeSurfer/FreeSurfer-7.1.1-centos* --download-timeout=1000 -r



FROM registry.access.redhat.com/ubi8/s2i-core:1 AS runner

USER 1001

# load from local easybuild-data folder
# COPY --chown=1001:0 easybuild-data/. /opt/app-root/src/easybuild-data/

# Load from multistage docker build
COPY --from=builder --chown=1001:0 /opt/apps/easybuild/ /opt/app-root/src/easybuild-data/

COPY copy_data.sh /opt/app-root/src/copy_data.sh
