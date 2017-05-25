pkg_name=neovim
pkg_origin=core
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="https://github.com/$pkg_name/$pkg_name.git"
pkg_dirname="$pkg_name-nightly"
pkg_deps=(
	core/jemalloc
  smith/libuv
  smith/libtermkey
  smith/libvterm
	smith/lpeg
	core/lua
	smith/luajit
  smith/msgpack
  smith/unibilium
)
pkg_build_deps=(
  core/cmake
  core/gcc
  core/git
  core/make
  core/ninja
  core/pkg-config
)
# pkg_lib_dirs=(lib)
# pkg_include_dirs=(include)
# pkg_bin_dirs=(bin)
# pkg_pconfig_dirs=(lib/pconfig)
pkg_description="Vim-fork focused on extensibility and usability"
pkg_upstream_url="https://neovim.io/"

pkg_version() {
  echo FIXME
}

do_download() {
  rm -rf "$CACHE_PATH"
  git clone --depth 1 "$pkg_source" "$CACHE_PATH"
  update_pkg_version
}

do_verify() {
  return 0
}

do_clean() {
  return 0
}

do_unpack() {
  return 0
}

do_prepare() {
  export CMAKE_INSTALL_PREFIX="$pkg_prefix"
  build_line "Setting CMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX"
	export LUA_PATH
	LUA_CPATH="$(pkg_path_for lpeg)/lib/lpeg.so"
  #export LIBUV_INCLUDE_DIR LIBUV_LIBRARY
  #LIBUV_INCLUDE_DIR="$(pkg_path_for libuv)/include"
  #build_line "Setting LIBUV_INCLUDE_DIR=$LIBUV_INCLUDE_DIR"
  #LIBUV_LIBRARY="$(pkg_path_for libuv)/lib/libuv.so"
  #build_line "Setting LIBUV_LIBRARY=$LIBUV_LIBRARY"
}

do_build() {
  mkdir "$CACHE_PATH/build"
  pushd "$CACHE_PATH/build" > /dev/null
    cmake .. \
      -DLIBUV_INCLUDE_DIR="$(pkg_path_for libuv)/include" \
      -DLIBUV_LIBRARY="$(pkg_path_for libuv)/lib/libuv.so"
  popd > /dev/null
  make
}

do_check() {
  return 0
}

do_install() {
  do_default_install
}

do_strip() {
  do_default_strip
}

do_end() {
  return 0
}
