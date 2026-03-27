#!/bin/sh

set -e

# git submodule update --init --recursive

brew install node
npm install -g pnpm

# $CI_WORKSPACE 是 Xcode Cloud 提供的环境变量，指向项目的根目录。
cd "$CI_WORKSPACE/repository"

pnpm ui:init

cd "$CI_WORKSPACE/repository"
pnpm web:install
pnpm web:build
