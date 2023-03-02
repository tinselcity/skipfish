#!/bin/bash
# ------------------------------------------------------------------------------
# requirements
# ------------------------------------------------------------------------------
which cmake gcc make || {
    echo "Failed to find required build packages. Please install with:   sudo apt-get install cmake make g++"
    exit 1
}
# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
main() {
    build_asan=0
    while getopts ":a" opt; do
        case "${opt}" in
            a)
                build_asan=1
            ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit $?
            ;;
        esac
    done
    if [ "$(uname)" == "Darwin" ]; then
        BUILD_UBUNTU=OFF
        NPROC=$(sysctl -n hw.ncpu)
    else
        BUILD_UBUNTU=ON
        NPROC=$(nproc)
    fi
    mkdir -p build
    pushd build
    if [[ "${build_asan}" -eq 1 ]]; then
        cmake ../ \
        -DDEBUG_MODE=ON\
        -DBUILD_ASAN=ON\
        -DBUILD_SYMBOLS=ON \
        -DBUILD_UBUNTU=${BUILD_UBUNTU} \
        -DCMAKE_INSTALL_PREFIX=/usr/local
    else
        cmake ../ \
        -DBUILD_SYMBOLS=ON \
        -DBUILD_UBUNTU=${BUILD_UBUNTU} \
        -DCMAKE_INSTALL_PREFIX=/usr/local
    fi
    make -j${NPROC} && \
    umask 0022 && chmod -R a+rX . && \
    make package && \
    popd && \
    exit $?
}
main "${@}"
