# shellcheck shell=bash

scaffolding_load() {
  _setup_funcs
  _setup_vars

  pushd "$SRC_PATH" > /dev/null
  _detect_app_type
  _detect_pkg_manager
  _detect_process_bins
  _update_vars
  _update_pkg_build_deps
  _update_pkg_deps
  _update_bin_dirs
  _update_svc_run
  popd > /dev/null
}

do_default_prepare() {
  return 0
}

do_default_build() {
  return 0
}

do_default_install() {
  return 0
}

do_default_strip() {
  # TODO fin: is it still risky to attempt `strip` on Go binaries?
  return 0
}

# This becomes the `do_default_build_config` implementation thanks to some
# function "renaming" above. I know, right?
_new_do_default_build_config() {
  local key dir env_sh

  _stock_do_default_build_config

  if [[ ! -f "$PLAN_CONTEXT/hooks/init" ]]; then
    build_line "No user-defined init hook found, generating init hook"
    mkdir -p "$pkg_prefix/hooks"
    cat <<EOT >> "$pkg_prefix/hooks/init"
#!/bin/sh
set -e

export HOME="$pkg_svc_data_path"
. '$pkg_svc_config_path/app_env.sh'

EOT
    chmod 755 "$pkg_prefix/hooks/init"
  fi

  if [[ -f "$CACHE_PATH/default.scaffolding.toml" ]]; then
    build_line "Appending Scaffolding defaults to $pkg_prefix/default.toml"
    cat "$CACHE_PATH/default.scaffolding.toml" >> "$pkg_prefix/default.toml"
  fi

  env_sh="$pkg_prefix/config/app_env.sh"
  mkdir -p "$(dirname "$env_sh")"
  for key in "${!scaffolding_env[@]}"; do
    echo "export $key='${scaffolding_env[$key]}'" >> "$env_sh"
  done
}




_setup_funcs() {
  # Use the stock `do_default_build_config` by renaming it so we can call the
  # stock behavior. How does this rate on the evil scale?
  _rename_function "do_default_build_config" "_stock_do_default_build_config"
  _rename_function "_new_do_default_build_config" "do_default_build_config"
}

_setup_vars() {
  # The default Go package if one cannot be detected
  _default_go_pkg="core/go"
  # `$scaffolding_go_pkg` is empty by default
  : "${scaffolding_go_pkg:=}"
  # The install prefix path for the app
  scaffolding_app_prefix="$pkg_prefix/app"
  #
  : "${scaffolding_app_port:=8000}"
  # If `${scaffolding_env[@]` is not yet set, setup the hash
  if [[ ! "$(declare -p scaffolding_env 2> /dev/null || true)" =~ "declare -A" ]]; then
    declare -g -A scaffolding_env
  fi
  # If `${scaffolding_process_bins[@]` is not yet set, setup the hash
  if [[ ! "$(declare -p scaffolding_process_bins 2> /dev/null || true)" =~ "declare -A" ]]; then
    declare -g -A scaffolding_process_bins
  fi

  _jq="$(pkg_path_for jq-static)/bin/jq"
}

_detect_app_type() {
  if [[ -f Godeps/Godeps.json \
    || -f vendor/vendor.json \
    || -f glide.yaml \
    || _uses_gb \
  ]]; then
    return 0
  else
    local e
    e="Go Scaffolding cannot find"
    e="$e Godeps/Godeps.json, vendor/vendor.json, glide.yaml, or src/**/*.go"
    exit_with "$e" 5
  fi
}

_detect_pkg_manager() {
  if [[ -n "$scaffolding_pkg_manager" ]]; then
    case "$scaffolding_pkg_manager" in
      godep)
        _pkg_manager=godep
        build_line "Detected package manager in Plan, using '$_pkg_manager'"
        ;;
      govendor)
        _pkg_manager=govendor
        build_line "Detected package manager in Plan, using '$_pkg_manager'"
        ;;
      glide)
        _pkg_manager=glide
        build_line "Detected package manager in Plan, using '$_pkg_manager'"
        ;;
      gb)
        _pkg_manager=gb
        build_line "Detected package manager in Plan, using '$_pkg_manager'"
        ;;
      *)
        local e
        e="Variable 'scaffolding_pkg_manager' can only be"
        e="$e set to: 'godep', 'govendor', 'glide', 'gb', or empty."
        exit_with "$e" 9
        ;;
    esac
  elif [[ -f Godeps/Godeps.json ]]; then
    _pkg_manager=godep
    build_line "Detected Godeps/Godeps.json, using '$_pkg_manager'"
    if ! "$_jq" . < Godeps/Godeps.json > /dev/null; then
      exit_with "Failed to parse Godeps/Godeps.json as JSON." 6
    fi
  elif [[ -f vendor/vendor.json ]]; then
    _pkg_manager=govendor
    build_line "Detected vendor/vendor.json, using '$_pkg_manager'"
    if ! "$_jq" . < vendor/vendor.json > /dev/null; then
      exit_with "Failed to parse vendor/vendor.json as JSON." 6
    fi
  elif [[ -f glide.yaml ]]; then
    _pkg_manager=glide
    build_line "Detected glide.yaml, using '$_pkg_manager'"
    # TODO fin: can we validate this YAML? Currently `rq -y < glide.yaml`
    # returns 0 on successful parse and on error. Maybe a PR upstream?
  elif _uses_gb; then
    _pkg_manager=gb
    build_line "Detected src/**/*.go, using '$_pkg_manager'"
  else
    # TODO fin: is there an appripriate default manager--maybe vanilla
    # `go get`?
    exit_with \
      "Go Scaffolding cannot determine the package manager to use." 10
  fi
}

_detect_process_bins() {
  if [[ -f Procfile ]]; then
    local line bin cmd

    build_line "Procfile detected, reading processes"
    # Procfile parsing was heavily inspired by the implementation in
    # gliderlabs/herokuish. Thanks to:
    # https://github.com/gliderlabs/herokuish/blob/master/include/procfile.bash
    while read -r line; do
      if [[ "$line" =~ ^#.* ]]; then
        continue
      else
        bin="${line%%:*}"
        cmd="${line#*:}"
        _set_if_unset scaffolding_process_bins "$(trim "$bin")" "$(trim "$cmd")"
      fi
    done < Procfile
  fi

  if [[ ! -v "scaffolding_process_bins[web]" && -z "$pkg_svc_run" ]]; then
    _set_if_unset scaffolding_process_bins "web" "$pkg_name"
    local m
    m="A default proccess bin called 'web' could not be detected from"
    m="$m a Procfile. Attempting to use the package name '$pkg_name'"
    m="$m as the program to run."
    build_line "$m"
  fi

  _set_if_unset scaffolding_process_bins "sh" 'sh'
}

_update_vars() {
  local val

  _set_if_unset scaffolding_env PORT "{{cfg.app.port}}"
  # Export the app's listen port
  _set_if_unset pkg_exports port "app.port"

  # TODO fin: anything else to set by default?
}

_update_pkg_build_deps() {
  # Order here is important--entries which should be first in
  # `${pkg_build_deps[@]}` should be called last.

  _detect_git

  # TODO fin: add pkg_manager tools

  _detect_go
}

_update_pkg_deps() {
  # Order here is important--entries which should be first in `${pkg_deps[@]}`
  # should be called last.

  _add_busybox
}

_update_bin_dirs() {
  # Add the `bin/` directory and the app's `bin/` directory to
  # the bin dirs so they will be on `PATH.  We do this after the existing
  # values so that the Plan author's `${pkg_bin_dir[@]}` will always win.
  pkg_bin_dirs=(
    ${pkg_bin_dir[@]}
    bin
    $(basename "$scaffolding_app_prefix")/bin
  )
}

_update_svc_run() {
  if [[ -z "$pkg_svc_run" ]]; then
    pkg_svc_run="$pkg_prefix/bin/${pkg_name}-web"
    build_line "Setting pkg_svc_run='$pkg_svc_run'"
  fi
}




_add_busybox() {
  build_line "Adding Busybox package to run dependencies"
  pkg_deps=(core/busybox-static ${pkg_deps[@]})
  debug "Updating pkg_deps=(${pkg_deps[*]}) from Scaffolding detection"
}

_detect_go() {
  if [[ -n "$scaffolding_go_pkg" ]]; then
    _go_pkg="$scaffolding_go_pkg"
    build_line "Detected Go version in Plan, using '$_go_pkg'"
  else
    local val
    case "$_pkg_manager" in
      godep)
        val="$(_json_val Godeps/Godeps.json .GoVersion)"
        if [[ -n "$val" ]]; then
          # TODO fin: Add more robust .GoVersion to Habitat package matching
          case "$val" in
            *)
              # TODO fin: is this value going to map to a version?
              _go_pkg="core/go/$val"
              ;;
          esac
          build_line "Detected Go version '$val' in Godeps/Godeps.json, using '$_go_pkg'"
        fi
        ;;
      govendor)
        # TODO fin: support .heroku.goVersion and possibly habitat.goVersion?
        ;;
      glide|gb)
        # TODO fin: there appears to be no common ways to express Go versions
        # with these tools
        ;;
      *)
        local e
        e="Internal error: package manager variable"
        e="$e not correctly set: '$_pkg_manager'"
        exit_with "$e" 9
        ;;
    esac
  fi
  if [[ -z "${_go_pkg:-}" ]]; then
    _go_pkg="$_default_go_pkg"
    build_line "No Go version detected in Plan or from a package manager, using default '$_go_pkg'"
  fi
  pkg_deps=($_go_pkg ${pkg_deps[@]})
  debug "Updating pkg_deps=(${pkg_deps[*]}) from Scaffolding detection"
}

_detect_git() {
  if [[ -d ".git" ]]; then
    build_line "Detected '.git' directory, adding git packages as build deps"
    pkg_build_deps=(core/git ${pkg_build_deps[@]})
    debug "Updating pkg_build_deps=(${pkg_build_deps[*]}) from Scaffolding detection"
    _uses_git=true
  fi
}




# With thanks to:
# https://github.com/heroku/heroku-buildpack-nodejs/blob/master/lib/json.sh
# shellcheck disable=SC2002
_json_val() {
  local json
  json="$1"
  path="$2"

  cat "$json" | "$_jq" --raw-output "$path // \"\""
}

# Heavily inspired from:
# https://gist.github.com/Integralist/1e2616dc0b165f0edead9bf819d23c1e
_rename_function() {
  local orig_name new_name
  orig_name="$1"
  new_name="$2"

  declare -F "$orig_name" > /dev/null \
    || exit_with "No function named $orig_name, aborting" 97
  eval "$(echo "${new_name}()"; declare -f "$orig_name" | tail -n +2)"
}

_set_if_unset() {
  local hash key val
  hash="$1"
  key="$2"
  val="$3"

  if [[ ! -v "$hash[$key]" ]]; then
    eval "$hash[$key]='$val'"
  fi
}





_uses_gb() {
  if [[ -d src && $(find src -name '*.go' -type f | wc -l) -gt 0 ]]; then
    return 0
  else
    return 1
  fi
}
