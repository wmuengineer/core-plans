pkg_name=bashdb
pkg_origin=core
pkg_version="4.3-0.91"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('GPL-2.0')
pkg_source="https://downloads.sourceforge.net/project/$pkg_name/$pkg_name/$pkg_version/$pkg_name-$pkg_version.tar.bz2"
pkg_shasum="60117745813f29070a034c590c9d70153cc47f47024ae54bfecdc8cd86d9e3ea"
pkg_deps=(
  core/bash
  core/coreutils
)
pkg_build_deps=(
  core/make
)
pkg_bin_dirs=(bin)
pkg_description="BASH Debugger"
pkg_upstream_url="http://bashdb.sourceforge.net/"

do_check() {
  make check
}
