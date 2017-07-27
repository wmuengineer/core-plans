pkg_name=scaffolding-go
pkg_origin=core
pkg_version="0.1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_description="Habitat Plan Scaffolding for Go Applications"
pkg_upstream_url="https://github.com/habitat-sh/core-plans/tree/master/scaffolding-go"
pkg_deps=(core/tar core/jq-static core/rq)
pkg_build_deps=(core/coreutils)

do_build() {
  return 0
}

do_install() {
  find lib -type f | while read -r f; do
    install -D -m 0644 "$f" "$pkg_prefix/$f"
  done
}
