Description
===========
This cookbook contains an LWRP to manage one-time-use encrypted filesystem
using the cryptsetup package in Debian and Ubuntu.  On each boot, a
filesystem-in-a-file will be created, mounted as a loop device, encrypted
via cryptsetup with a randomly-generated key that isn't stored anywhere,
and mounted for use.  It isn't necessary to reboot for the filesystem
resources to become available, but they will be created anew each time a
machine reboots.

The intended purpose of this cookbook is for deploying servers which will
handle sensitive information on untrusted systems or cloud deployments, so
that the filesystems themselves will not be readable outside the running
instance. Information stored in the encrypted filesystem will be irretrievable
after reboot.

Requirements
============

## Platform

Tested on:
* Debian 6.0
* Ubuntu 12.04

This cookbook will only work on Debian or Ubuntu systems if the `cryptsetup`
package is available.  The `cryptsetup` package will be installed if it's not
already present.

Attributes
==========
* `node['encryptfs'['uninstall_cryptsetup_iflast']` - Sets the cookbook to
  remove the `cryptsetup` packages after the last filesystem is removed from
  `/etc/crypttab`.  Default is `false`, to leave the packages installed. Only
  the `cryptsetup` and `cryptsetup-bin` packages will be uninstalled if this is
  `true`.
* `node['encryptfs']['cryptdisks_path']` `node['encryptfs']['cryptdisks_stop']`
  `node['encryptfs']['cryptdisks_start']` - All used to set paths for the
  scripts that are part of the cryptsetup package.  They are in a different
  place in Ubuntu.

Recipes
=======
## default
The default recipe won't do anything.

## example
This represents an example of creating a few small encrypted filesystems. You
really should be using this cookbook only as an LWRP.

Resource/Provider
=================
This cookbook includes an LWRP, `encryptfs`, for managing one-time-use
encrypted filesystems.

    encryptfs "data" do
      size 100
      filepath "/cryptfs"
      mountpath "/usr/local/cryptdata"
      action :create
    end

The `size` is specified in megabytes.  The `filepath` is where the file of
that size is to be created in your existing filesystems.  That file will
become a loop device containing the encrypted block data.  The `mountpath` will
be where the encrypted filesystem is to be mounted.  The LWRP supports both
`:create` and `:delete` actions.

Usage
=====
Put the following in your cookbook's metadata.rb file to include this LWRP:

    depends "encryptfs"

The following added to your recipes will create an encrypted filesystem:

    encryptfs "data" do
      size 100
      filepath "/cryptfs"
      mountpath "/usr/local/cryptdata"
      fstype "ext4"
      action :create
    end

The following added to your recipe will delete an encrypted filesystem:

    encryptfs "data" do
      action :delete
    end

License and Authors
-------------------
Author: Neil Schelly (@neilschelly)

Copyright 2013, Dyn, Inc (@DynInc)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,  
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
