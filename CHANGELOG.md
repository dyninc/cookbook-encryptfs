# CHANGELOG for encryptfs

This file is used to list changes made in each version of encryptfs.

## 1.0.1:
* Fixed #1: issue where the service cryptdisks reload wasn't a reliable means to
  ensure that new disks get created/mapped in time to be mounted.

## 1.0.0:
* Added an attribute that can be overwridden to control uninstalling the
  cryptsetup and cryptsetup-bin packages if the last crypttab entry is removed.
* Converted tabs to 2-space Ruby convention.

## 0.9.0:
* Converting tabs to spaces, more Ruby friendly
* Updating metadata.rb, README, etc for more release-friendliness.
* Includes support for multiple encrypted filesystems at once.

## 0.9.0:
* Converted encryptfs to an LWPR instead of a recipe.
* Created sample recipe to replace default.
* Updated documentation.
TODO: Needs support for multiple filesystems, managing /etc/crypttab smarter, and
      removing the cryptsetup package if there are no encrypted filesystems left.

## 0.1.0:

* Initial release of encryptfs

