#!/usr/bin/env bash

MASON_NAME=mesa
MASON_BASE_VERSION=13.0.3
MASON_VERSION=${MASON_BASE_VERSION}-dynamic-llvm

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://mesa.freedesktop.org/archive/${MASON_BASE_VERSION}/mesa-${MASON_BASE_VERSION}.tar.gz \
        c65114c3566674642f698580efc136fe1fe19c67

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/mesa-${MASON_BASE_VERSION}
}

function mason_prepare_compile {
    true
}

function mason_compile {
    CFLAGS=-g CXXFLAGS=-g \
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-opengl \
        --enable-gles1 \
        --enable-gles2 \
        --enable-egl \
        --disable-osmesa \
        --enable-gallium-osmesa \
        --enable-gbm \
        --enable-dri \
        --disable-dri3 \
        --enable-gallium-llvm \
        --enable-glx \
        --enable-glx-tls \
        --enable-texture-float \
        --enable-shared-glapi \
        --enable-valgrind \
        --with-dri-drivers=swrast \
        --with-gallium-drivers=swrast \
        --with-egl-platforms=x11,drm,surfaceless \
        --with-llvm-prefix=/usr/lib/llvm-3.8 \
        --with-sha1=libcrypto

    make
    make install
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    # We include just the library path. Users are expected to provide additional flags
    # depending on which of the packaged libraries they actually want to link:
    #
    #    * For GLX: -lGL -lX11
    #    * For EGL: -lGLESv2 -lEGL -lgbm
    #    * For OSMesa: -lOSMesa
    #
    echo -L${MASON_PREFIX}/lib
}

function mason_clean {
    make clean
}

mason_run "$@"