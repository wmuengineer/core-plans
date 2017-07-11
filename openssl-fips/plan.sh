pkg_name=openssl-fips
pkg_origin=core
pkg_version=2.0.16
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="OpenSSL is an open source project that provides a robust, commercial-grade, and full-featured toolkit for the Transport Layer Security (TLS) and Secure Sockets Layer (SSL) protocols. It is also a general-purpose cryptography library."
pkg_license=('OpenSSL')
pkg_upstream_url="https://www.openssl.org"
pkg_source=https://www.openssl.org/source/${pkg_name}-${pkg_version}.tar.gz
pkg_shasum=a3cd13d0521d22dd939063d3b4a0d4ce24494374b91408a05bdaca8b681c63d4
pkg_deps=(core/glibc core/zlib core/cacerts)
pkg_build_deps=(core/coreutils core/diffutils core/patch core/make core/gcc core/sed core/grep core/perl)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include/openssl)
pkg_lib_dirs=(lib)

do_prepare() {
  grep -lr '/bin/rm' . | while read -r f; do
    sed -e 's,/bin/rm,rm,g' -i "$f"
  done
  export BUILD_CC=gcc
  build_line "Setting BUILD_CC=$BUILD_CC"
}

do_build() {
  PERL=$(pkg_path_for core/perl)/bin/perl
  export PERL
  ./config \
  zlib \
  --prefix="${pkg_prefix}" \
  --openssldir="ssl"
  make
}

do_check() {
  make test
}

# ----------------------------------------------------------------------------
# **NOTICE:** What follows are implementation details required for building a
# first-pass, "stage1" toolchain and environment. It is only used when running
# in a "stage1" Studio and can be safely ignored by almost everyone. Having
# said that, it performs a vital bootstrapping process and cannot be removed or
# significantly altered. Thank you!
# ----------------------------------------------------------------------------
if [[ "$STUDIO_TYPE" = "stage1" ]]; then
  pkg_build_deps=(core/gcc core/coreutils core/sed core/grep core/perl core/diffutils core/make core/patch)
fi
