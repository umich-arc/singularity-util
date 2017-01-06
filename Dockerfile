FROM ubuntu:16.04
MAINTAINER ARC-TS <arcts-dev@umich.edu>

ARG SINGULARITY_VERSION=2.2

LABEL name="Singularity-Util" \
      license="MIT"           \
      Singularity.Version=$SINGULARITY_VERSION

RUN apt-get update     \
 && apt-get -y install \
    autoconf        \
    automake        \
    autotools-dev   \
    build-essential \
    debhelper       \
    dh-autoreconf   \
    git             \
    libtool         \
    python          \
    rpm             \
    sudo            \
 && mkdir build     \
 && mkdir target    \
 && apt-get -y autoremove \
 && apt-get -y clean      \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./skel /

RUN chmod +x ./build.sh \
 && chmod +x ./init.sh  \
 && ./build.sh

ENTRYPOINT [ "./init.sh" ]
