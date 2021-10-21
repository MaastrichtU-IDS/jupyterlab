# FROM quay.io/guimou/easybuild-ubi8-py39 AS builder

# RUN mkdir -p /opt/apps/easybuild/repos
# WORKDIR /opt/apps/easybuild/repos
# RUN git clone https://github.com/easybuilders/easybuild-easyconfigs
# RUN sed -i '\!^robot-paths! s!$!:/opt/apps/easybuild/repos/easybuild-easyconfigs/!' /opt/apps/easybuild/easybuild.d/config.cfg



FROM registry.access.redhat.com/ubi8/s2i-core:1

USER 1001

COPY --chown=1001:0 easybuild-data/. /opt/app-root/src/easybuild-data/

# COPY --from=builder --chown=1001:0 /opt/apps/easybuild/ /opt/app-root/src/easybuild-data/

COPY copy_data.sh /opt/app-root/src/copy_data.sh
