#!/bin/bash

brew update
brew upgrade

# Search
brew install ripgrep fd

# Go
brew install go gopls

# C / C++ tooling
brew install llvm

# Bash tooling
brew install shellcheck shfmt node

# Bash language server
npm install -g bash-language-server
