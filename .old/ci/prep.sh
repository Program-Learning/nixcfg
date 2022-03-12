#!/usr/bin/env bash
set -euo pipefail
set -x

cachix use colemickens

ssh-keyscan github.com >> ${HOME}/.ssh/known_hosts

git config --global user.name \
 "Cole Botkens"

git config --global user.email \
 "cole.mickens+colebot@gmail.com"

git status
