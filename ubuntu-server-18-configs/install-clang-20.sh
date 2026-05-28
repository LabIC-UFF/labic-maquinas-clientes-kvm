#!/bin/bash

clang --version
echo "ONLY RUN THIS SCRIPT IF CLANG VERSION IS BELOW 20! (LIKE CLANG 18...)"

# Install clang-20 and related tools
sudo apt install clang-20 clang-tools-20 clangd-20 clang-format-20 clang-tidy-20 libc++-20-dev

echo "Making clang 20 default, instead of clang 18"

# Update alternatives for each tool
for tool in clang clang++; do
  sudo update-alternatives --install /usr/bin/$tool $tool /usr/bin/${tool}-20 100
  sudo update-alternatives --set $tool /usr/bin/${tool}-20
done

# Handle clang-format and clangd separately (they may not have alternatives set up)
for tool in clang-format clangd; do
  sudo update-alternatives --install /usr/bin/$tool $tool /usr/bin/${tool}-20 100
  sudo update-alternatives --set $tool /usr/bin/${tool}-20
done
