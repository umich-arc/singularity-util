#!/bin/bash

cmd_check() {
  [[ $# -gt 1 ]] || exit 1
  cd /target || exit 1
}

build_deb() {
  cd /build/singularity || exit 1
  DEB_BUILD_OPTIONS=nocheck fakeroot dpkg-buildpackage -b -us -uc
  mv ../singularity-*.deb /target
}

build_rpm() {
  cd /build/singularity || exit 1
  make dist
  rpmbuild -ta               \
    --define="_rpmdir /tmp"  \
    singularity-*.tar.gz
  mv /tmp/x86_64/*.rpm /target
}

s_build() {
  if [[ $# -eq 0 ]]; then
    build_deb
    build_rpm
  else
    for item in "$@"; do
      case "${item,,}" in
        deb) build_deb ;;
        rpm) build_rpm ;;
      esac
    done
  fi
}

s_cmd() {
  cmd_check "$@"
  singularity "$@"
}

usage() {
version=$(singularity --version)
cat <<EOF
######################### singularity-util ####################################
#  A Docker based container that provides methods of working with Singularity #
#  based containers. Useful for integration with Docker centric build systems #
######################### singularity-util ####################################

Singularity Version: $version

General Usage:

  docker run --rm --privileged -v \$(pwd):/target:rw \\
    singularity-util <command> <args>

Supported Singularity commands will be passed automatically after the working 
directory has been set to '/target'. Anything that is intended to be worked 
with should be mounted to that location, and all paths supplied to the 
singularity-util container should assume '/target' as the current working 
directory.

Supported Singularity Commands:
  bootstrap|copy|create|expand|exec|export|import|run|shell|test

Non Singularity Commands:
  build|debug

  build [rpm|deb]
    Builds redistributable packages in both RPM or DEB form. If no option is 
    supplied, both types of packages will be built.

    Example:
      docker run --rm -v \$(pwd):/target:rw singularity-util build deb

  debug [args]:
    Exits the script and drops to a bash shell (useful for troubleshooting). 
    If parameters are supplied, they will be passed to the shell.
      
    Example:
      docker run -it --privileged -v \$(pwd):/target:rw singularity-util debug
EOF

}

main() {
  case "${1,,}" in
    bootstrap|copy|create|expand|exec|export|import|run|shell|test) s_cmd "$@" ;;
    build) shift; s_build "$@" ;;
    debug) shift; exec /bin/bash "$@" ;;
    *) usage ;;
  esac
}

main "$@"
