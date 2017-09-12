pkg_name=cassandra
pkg_origin=core
pkg_version="3.11.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_source="http://ftp.jaist.ac.jp/pub/apache/cassandra/3.11.0/apache-cassandra-3.11.0-bin.tar.gz"
pkg_shasum="d597b99b402bd2cf925033519db9e58340acb893fd83d600d904ba4041d44fa7"
pkg_dirname="apache-${pkg_name}-${pkg_version}"
pkg_deps=(core/jre8 core/python)
pkg_build_deps=()
pkg_lib_dirs=(lib pylib)
pkg_bin_dirs=(bin)
pkg_exposes=(
  rpc_port
  native_transport_port
  storage_port
)
pkg_exports=(
  [rpc_port]="rpc.port"
  [native_transport_port]="native_transport.port"
  [storage_port]="storage_port"
)
pkg_binds_optional=(
  [cassandra]="storage_port"
)
pkg_description="Manage massive amounts of data, fast, without losing sleep."
pkg_upstream_url="http://cassandra.apache.org/"

do_build() {
  return 0
}

do_build_config() {
  do_default_build_config
  rm "${HAB_CACHE_SRC_PATH}/${pkg_dirname}/conf/cassandra.yaml"
  cp -rv "${HAB_CACHE_SRC_PATH}/${pkg_dirname}/conf/"* "${pkg_prefix}/config"
}

do_install() {
  pushd "lib/sigar-bin" > /dev/null
  find . ! -name "libsigar-amd64-linux.so" -type f -exec rm -f {} +
  popd > /dev/null
  cp -rv . "${pkg_prefix}/"
}
