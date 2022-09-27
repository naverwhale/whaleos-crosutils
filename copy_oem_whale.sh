#!/bin/bash

# copy_oem_whale
copy_oem_whale() {
  local src_dir="./oem_whale/"
  local dst_dir="/opt/oem/"

  if [ -d "$dst_dir" ];then
    sudo rm -rf "$dst_dir"
  fi

  sudo cp -r "$src_dir" "$dst_dir"
  echo "COPY oem_whale success"
}

copy_oem_whale
