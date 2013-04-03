#
# Cookbook Name:: encryptfs
# Attributes:: default
#
# Copyright 2013, Neil Schelly
# Copyright 2013, Dyn, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


def whyrun_supported?
  true
end


action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_encryptfs
    end
    new_resource.updated_by_last_action(true)
  end
end


action :delete do
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      delete_encryptfs
    end
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.info "#{ @current_resource } doesn't exist - can't delete."
  end
end


def load_current_resource
  @current_resource = Chef::Resource::Encryptfs.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.mountpath(new_resource.mountpath)
  if encryptfs_exists?(@current_resource.name)
    @current_resource.exists = true
  end
end    

#######################################################

def create_encryptfs
  # Install cryptsetup
  package "cryptsetup" do
    action [ :install, :upgrade ]
  end

  # Ensure service remains enabled, started, etc
  service "cryptdisks" do
    action [ :enable, :start ]
  end

  # create file for loop block device
  file @new_resource.filepath do
    owner "root"
    group "root"
    mode "00600"
    action :create_if_missing
    notifies :run, "execute[set-file-size]", :immediately
  end
  
  # Set file size for loop file
  execute "set-file-size" do
    command "/bin/dd of=#{new_resource.filepath} if=/dev/zero bs=1M count=#{new_resource.size}"
    action :nothing
  end

  # verify that crypttab is present
  file "/etc/crypttab" do
    owner "root"
    group "root"
    mode "0644"
    action :create_if_missing
  end
  
  # create entry in /etc/crypttab
  ruby_block "add_crypttab_#{new_resource.name}" do
    block do
      if ( !(encryptfs_crypttab_exists?(new_resource.name)) )
        Chef::Log.info("#{new_resource.name} wasn't found in /etc/crypttab")
        encryptfs_crypttab_add(new_resource.name, new_resource.filepath, new_resource.fstype)
      end
    end
    notifies :run, "execute[cryptdisks_start]", :immediately
  end
  
  # Provide service to notify, in order to reload crypttab
  execute "cryptdisks_start" do
    command "#{node[:encryptfs][:cryptdisks_start]} #{new_resource.name}"
    action :nothing
  end
  
  # Create mount point
  directory @new_resource.mountpath do
    owner "root"
    group "root"
    action :create
    recursive true
  end  
  
  # create and mount entry in fstab
  mount @new_resource.mountpath do
    device "/dev/mapper/#{new_resource.name}"
    fstype new_resource.fstype
    action [ :mount, :enable ]
  end
end


def delete_encryptfs
  # Unmount and remove entry from fstab
  mount @new_resource.mountpath do
    device "/dev/mapper/#{new_resource.name}"
    fstype new_resource.fstype
    action [ :umount, :disable ]
  end

  # delete mount point
  directory @new_resource.mountpath do
    action :delete
  end
  
  # deactivate encrypted filesystem
  execute "remove-encryptfs" do
    command "/sbin/cryptsetup remove #{new_resource.name}"       
    action :run      
  end
  
  # remove encrypted filesystem from crypttab
  ruby_block "delete_crypttab_#{new_resource.name}" do
    block do
      if ( encryptfs_crypttab_exists?(new_resource.name) )
        encryptfs_crypttab_delete(new_resource.name)
      end
    end
  end
  
  # delete file for loop block device
  file @new_resource.filepath do
    action :delete
  end  

  # Uninstall cryptsetup packages if configured to do so
  ruby_block "uninstall_cryptsetup" do
    block do
      uninstall_cryptfs if node[:encryptfs][:uninstall_cryptsetup_iflast]
    end
  end
end


def uninstall_cryptfs
  # Scan for there non-blank, non-comment lines in crypttab
  ::File.readlines("/etc/crypttab").reverse_each do |line|
    if (!(line =~ /^#/ or line =~ /^\s*$/ ))
      Chef::Log.info("Not removing cryptsetup because crypttab contains encrypted volumes.")
      return
    end
  end

  # Didn't find any non-blank, non-comment lines in crypttab
  Chef::Log.info("Removing cryptsetup package because crypttab is empty.")
  package "cryptsetup" do
    action :remove
  end
  
  # Debian only uses the cryptsetup package, but Ubuntu has both.
  package "cryptsetup-bin" do
    action :remove
  end
end


def encryptfs_exists?(name)
  # Return code of 0 only when the name exists and is active.
  return system("/sbin/cryptsetup status #{name}")
end


def encryptfs_crypttab_exists?(name)
  # If crypttab doesn't exist, then we know #{name} isn't in it.
  if (! ::File.exists?( "/etc/crypttab" ))
    return false
  end
  
  # Scan through crypttab
  ::File.foreach("/etc/crypttab") do |line|
    # Return true if we find a line beginning with #{name}
    return true if ( line =~ /^#{name} / )
  end
  
  # Failed to find #{name} in crypttab
  return false
end


def encryptfs_crypttab_add(name, filepath, fstype)
  # Append newline for the new encryptfs to the /etc/crypttab
  newline = "#{name} \t#{filepath}\t /dev/urandom \ttmp=#{fstype},cipher=aes-cbc-essiv:sha256,noearly\n"
  ::File.open("/etc/crypttab", "a") do |crypttab|
    crypttab.puts(newline)
  end
end


def encryptfs_crypttab_delete(name)
  # contents will be a list of lines to _keep_ in the file when we rewrite it.
  contents = []
  ::File.readlines("/etc/crypttab").reverse_each do |line|
    if (!(line =~ /^#{name} / ))
      contents << line
    else
      # Skip copying the deleted encryptfs into the contents array
      Chef::Log.info("#{@new_resource} is removed from crypttab")
    end
  end
  
  # Write out the contents array as lines in a new /etc/crypttab.
  ::File.open("/etc/crypttab", "w") do |crypttab|
    contents.reverse_each { |line| crypttab.puts line }
  end
end

