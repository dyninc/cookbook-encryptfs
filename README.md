encryptfs Cookbook
========================
This cookbook will create a one-boot-use encrypted filesystem using the
cryptsetup package in Debian and Ubuntu.  On each boot, a filesystem-in-a-file
will be created, mounted as a loop device, encrypted via cryptsetup with a
randomly-generated key that isn't stored anywhere, and mounted for use.

The intended purpose of this cookbook is for deploying servers which will
handle sensitive information on untrusted systems or cloud deployments, so
that the filesystems themselves will not be readable outside the running
instance. Information stored in the encrypted filesystem will be irretrievable
after reboot.

Requirements
------------
This cookbook will only work on Debian or Ubuntu systems if the cryptsetup
package is available.  The cryptsetup package will be installed if it's not
already present.

Attributes
----------
#### encryptfs::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['encryptfs']['size']</tt></td>
    <td>Integer</td>
    <td>Size of filesystem in megabytes</td>
    <td><tt>100</tt></td>
  </tr>
  <tr>
    <td><tt>['encryptfs']['filepath']</tt></td>
    <td>String</td>
    <td>Location of file to store filesystem.</td>
    <td><tt>/cryptfs</tt></td>
  </tr>
  <tr>
    <td><tt>['encryptfs']['name']</tt></td>
    <td>String</td>
    <td>Name of encrypted filesystem</td>
    <td><tt>data</tt></td>
  </tr>
  <tr>
    <td><tt>['encryptfs']['fstype']</tt></td>
    <td>String</td>
    <td>Type of filesystem created in encrypted block device (ext2/3/4 supported)</td>
    <td><tt>ext4</tt></td>
  </tr>
  <tr>
    <td><tt>['encryptfs']['mountpath']</tt></td>
    <td>String</td>
    <td>Mount point for the encrypted filesystem.</td>
    <td><tt>/usr/local/data/</tt></td>
  </tr>
</table>

Usage
-----
#### encryptfs::default
Adjust the attributes to suit your needs.  Make sure there's enough room in the
filesystem that will contain the file for the size specified.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[encryptfs]"
  ]
}
```

License and Authors
-------------------
Authors: Neil Schelly