#!/bin/bash
clang --version
echo "ONLY RUN THIS SCRIPT IF CLANG VERSION IS BELOW 20! (LIKE CLANG 18...)"
sudo apt install clang-20 clang-tools-20 clangd-20 clang-format-20 clang-tidy-20 libc++-20-dev
echo "make clang 20 default, instead of clang 18"
for tool in clang clang++ clang-format clangd; do
  sudo update-alternatives --install /usr/bin/$tool $tool /usr/lib/llvm-20/bin/${tool}-20 100
  sudo update-alternatives --set $tool /usr/lib/llvm-20/bin/${tool}-20
done
