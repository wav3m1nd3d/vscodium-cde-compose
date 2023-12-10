#!/bin/bash
set -e
apt-get -qq update
apt-get -qq --no-install-recommends upgrade
apt-get -qq --no-install-recommends install $CONT_BASE_PKGS $CONT_PKGS
apt-get -qq --no-install-recommends clean
rm -fr /var/lib/apt/lists/*
