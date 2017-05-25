pkg_name=lpeg
pkg_origin=core
pkg_version="1.0.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
# pkg_license=('Apache-2.0')
pkg_source="http://www.inf.puc-rio.br/~roberto/$pkg_name/$pkg_name-${pkg_version}.tar.gz"
pkg_shasum="62d9f7a9ea3c1f215c77e0cadd8534c6ad9af0fb711c3f89188a8891c72f026b"
pkg_build_deps=(
  core/gcc
  core/lua
  core/make
)
pkg_lib_dirs=(lib)
# pkg_description="Some description."
# pkg_upstream_url="http://example.com/project-name"

do_build() {
  make
}

do_install() {
  install -v -m 0755 "$CACHE_PATH/lpeg.so" "$pkg_prefix/lib/lpeg.so"
}
