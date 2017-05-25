pkg_origin=core
pkg_name=nethack
pkg_version=3.6.0
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('NGPL')
pkg_source=http://tenet.dl.sourceforge.net/project/${pkg_name}/${pkg_name}/${pkg_version}/${pkg_name}-360-src.tgz
pkg_dirname=${pkg_name}-${pkg_version}
pkg_shasum=1ade698d8458b8d87a4721444cb73f178c74ed1b6fde537c12000f8edf2cb18a
pkg_description="NetHack is a single player dungeon exploration game"
pkg_upstream_url="http://nethack.org/"
pkg_deps=(
  core/glibc
  core/ncurses
)
pkg_build_deps=(
  core/bison
  core/coreutils
  core/flex
  core/gcc
  core/groff
  core/make
  core/m4
  core/util-linux
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_prepare() {
  sed -e 's|^/\* \(#define LINUX\) \*/|\1|' \
      -e 's|^/\* \(#define TIMED_DELAY\) \*/|\1|' -i "$CACHE_PATH/include/unixconf.h"

  export CFLAGS="$CFLAGS -I../include"
  export HACKDIR="$pkg_prefix/var"

  pushd "$CACHE_PATH/sys/unix" > /dev/null
    ./setup.sh "$(realpath --relative-to=. "$PLAN_CONTEXT/habitat-hints")"
  popd > /dev/null
}

do_build() {
  make all
}
