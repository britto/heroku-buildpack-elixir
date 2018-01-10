function erlang_tarball() {
  echo "OTP-${erlang_version}.tar.gz"
}

function download_erlang() {
  erlang_package_url="https://s3.amazonaws.com/heroku-buildpack-elixir/erlang/cedar-14"
  erlang_package_url="${erlang_package_url}/$(erlang_tarball)"

  output_section "Tarball location: ${cache_path}/$(erlang_tarball)"

  # If a previous download does not exist, then always re-download
  if [ ! -f ${cache_path}/$(erlang_tarball) ]; then
    clean_erlang_downloads

    # Set this so elixir will be force-rebuilt
    erlang_changed=true

    output_section "Fetching Erlang ${erlang_version}"
    curl -s ${erlang_package_url} -o ${cache_path}/$(erlang_tarball) || exit 1
  else
    output_section "Using cached Erlang ${erlang_version}"
  fi
}

function clean_erlang_downloads() {
  rm -rf ${cache_path}/OTP-*.tar.gz
}

function install_erlang() {
  output_section "Installing Erlang ${erlang_version} $(erlang_changed)"

  output_line "Build path: ${build_path}"
  output_line "Runtime path: ${runtime_path}"
  output_line "Cache path: ${cache_path}"

  output_line "Platform tools path: $(platform_tools_path)"
  output_line "Erlang path: $(erlang_path)"

  output_line "Runtime platform tools path: $(runtime_platform_tools_path)"
  output_line "Runtime Erlang path: $(runtime_erlang_path)"

  output_line "Elixir path: $(elixir_path)"
  output_line "Erlang build path: $(erlang_build_path)"

  output_line "rm -rf $(erlang_build_path)"
  rm -vrf $(erlang_build_path)
  output_line "mkdir -vp $(erlang_build_path)"
  mkdir -vp $(erlang_build_path)
  output_line "tar zxf ${cache_path}/$(erlang_tarball) -C $(erlang_build_path) --strip-components=1"
  tar zxf ${cache_path}/$(erlang_tarball) -C $(erlang_build_path) --strip-components=1

  output_line "rm -rf $(runtime_erlang_path)"
  rm -vrf $(runtime_erlang_path)
  output_line "mkdir -p $(runtime_platform_tools_path)"
  mkdir -vp $(runtime_platform_tools_path)
  output_line "ln -s $(erlang_build_path) $(runtime_erlang_path)"
  ln -vs $(erlang_build_path) $(runtime_erlang_path)
  output_line "$(erlang_build_path)/Install -minimal $(runtime_erlang_path)"
  $(erlang_build_path)/Install -minimal $(runtime_erlang_path)

  output_line "cp -R $(erlang_build_path) $(erlang_path)"
  cp -vR $(erlang_build_path) $(erlang_path)

  ls -la $(erlang_build_path)
  ls -la $(erlang_path)

  output_line "setting PATH to: $(erlang_path)/bin:$PATH"
  PATH=$(erlang_path)/bin:$PATH
}

function erlang_changed() {
  if [ $erlang_changed = true ]; then
    echo "(changed)"
  fi
}
