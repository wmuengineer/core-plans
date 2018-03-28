pkg_name=chartmuseum
pkg_origin=core
pkg_version="v0.4.2"
pkg_source="https://s3.amazonaws.com/chartmuseum/release/${pkg_version}/bin/linux/amd64/chartmuseum"
pkg_shasum="69ad83a0f3a41613a539954d7dae112037fe141b5e244a522d65c52e2abaa9f1"
pkg_deps=(core/aws-cli)
pkg_bin_dirs=(bin)

do_unpack() {
  return 0
}

do_build() {
  return 0
}

do_install() {
  chmod +x "$HAB_CACHE_SRC_PATH/chartmuseum"
  mkdir -p "${pkg_prefix}/bin"
  install -D "$HAB_CACHE_SRC_PATH/chartmuseum" "${pkg_prefix}/bin/"
}