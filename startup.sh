#!/bin/bash

# Copyright 2015 Ronoaldo JLP
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script can be used as a startup script to launch and setup
# a development box with Orion (https://orion.eclipse.org/)

# Debug during VM preparation
if [ x"$DEBUG" == x"true" ] ; then
	set -e
	set -x
fi

# Helper function to fetch instance custom metadata
# Usage:
#   metadata key default-value
metadata() {
  _url="http://metadata.google.internal/computeMetadata/v1/instance/$1"
	# Return the value found, or the default value if the metadata value does not exists
	if curl --fail -s ${_url} -H 'Metadata-Flavor: Google' > /dev/null ; then
		curl --fail -s ${_url} -H 'Metadata-Flavor: Google'
	else
		echo -n "$2"
	fi
}

# Quiet installation for debian packages
export DEBIAN_FRONTEND=noninteractive

# Setup testing, with negative pinning
echo "Installing base software ... "

# Update package lists and upgrade installed programs
sudo apt-get -qq update && sudo apt-get -qq upgrade --yes

# Install/upgrade packages in the VM
sudo apt-get install -qq --yes \
    tmux vim nano emacs exuberant-ctags command-not-found bash-completion \
    git zsh libxml2-dev \
    build-essential devscripts \
    curl wget \
    npm npm2deb nodejs \
    python-dev python3-dev \
    docker.io \
    sqlite3 maven google-cloud-sdk-app-engine-go

# Post-install setup
update-command-not-found

# Cron shutdown vm
echo "30 22     * * *     root   /sbin/shutdown" > /etc/cron.d/desligar-vm-appratico