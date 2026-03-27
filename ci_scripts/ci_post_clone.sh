#!/bin/sh

set -e

# git submodule update --init --recursive

brew install node
npm install -g pnpm

# $CI_PRIMARY_REPOSITORY_PATH 是 Xcode Cloud 提供的环境变量，指向项目的根目录。
cd $CI_PRIMARY_REPOSITORY_PATH

pnpm ui:init

cd $CI_PRIMARY_REPOSITORY_PATH
pnpm web:install
pnpm web:build
