ARG BASE_IMAGE=adoptopenjdk/openjdk8:slim
FROM $BASE_IMAGE

ENV RUN_USER                                        fisheye
ENV RUN_GROUP                                       fisheye
ENV RUN_UID                                         2004
ENV RUN_GID                                         2004

ENV FISHEYE_INST                                  /var/atlassian/application-data/fisheye
ENV FISHEYE_INSTALL_DIR                           /opt/atlassian/fisheye

WORKDIR $FISHEYE_INST

EXPOSE 8060

CMD ["/entrypoint.py"]
ENTRYPOINT ["/sbin/tini", "--"]

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends unzip fontconfig openssh-client perl python3 python3-jinja2 \
    && apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

COPY bin/make-git.sh                                /
RUN /make-git.sh

ARG TINI_VERSION=v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
RUN chmod +x /sbin/tini

ARG FISHEYE_VERSION

ARG DOWNLOAD_URL=https://product-downloads.atlassian.com/software/fisheye/downloads/fisheye-${FISHEYE_VERSION}.zip

RUN set -ex && groupadd --gid ${RUN_GID} ${RUN_GROUP} \
    && useradd --uid ${RUN_UID} --gid ${RUN_GID} --home-dir ${FISHEYE_INST} --shell /bin/bash ${RUN_USER} \
    && echo PATH=$PATH > /etc/environment \
    \
    && mkdir -p                                     ${FISHEYE_INSTALL_DIR} \
    && curl -L                                      ${DOWNLOAD_URL} -o /tmp/fisheye.zip \
    && cd /tmp/ && unzip /tmp/fisheye.zip && mv /tmp/fecru-${FISHEYE_VERSION}/* ${FISHEYE_INSTALL_DIR} && rm -rf /tmp/fisheye.zip /tmp/fecru-${FISHEYE_VERSION} \
    && chmod -R "u=rwX,g=rX,o=rX"                   ${FISHEYE_INSTALL_DIR}/ \
    && chown -R root.                               ${FISHEYE_INSTALL_DIR}/ \
    && chown -R ${RUN_USER}:${RUN_GROUP}            ${FISHEYE_INST}

VOLUME ["${FISHEYE_INST}"]

COPY entrypoint.py \
     shared-components/image/entrypoint_helpers.py  /
COPY shared-components/support                      /opt/atlassian/support
COPY config/*                                       /opt/atlassian/etc/
