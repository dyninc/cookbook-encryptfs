#
# Cookbook Name:: encryptfs
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node[:platform]
when "ubuntu","debian"

	# Install cryptsetup (for Debian)
	package "cryptsetup" do
		action [ :install, :upgrade ]
	end

	# create file for loop block device
	# ARGS: size, path file
	file node['encryptfs']['filepath'] do
		owner "root"
		group "root"
		mode "00600"
		action :create_if_missing
		notifies :run, "execute[set-file-size]", :immediately
	end
	execute "set-file-size" do
		command "/bin/dd of=#{node['encryptfs']['filepath']} if=/dev/zero bs=1048576 count=#{node['encryptfs']['size']}"
		action :nothing
	end

	# create cryptsetup entry in /etc/crypttab
	# ARGS: name of block device, path to file, fs type
	file "/etc/crypttab" do
		owner "root"
		group "root"
		mode "0644"
		content "#{node['encryptfs']['name']} #{node['encryptfs']['filepath']} /dev/urandom tmp=#{node['encryptfs']['fstype']},cipher=aes-cbc-essiv:sha256,noearly"
		action :create
		notifies :run, "execute[reload-crypttab]", :immediately
	end
	execute "reload-crypttab" do
		command "/etc/init.d/cryptdisks reload"
		action :nothing
	end
	
	# create entry in fstab
	# ARGS: name of block device, path to mount, fs type
	directory node['encryptfs']['mountpath'] do
		owner "root"
		group "root"
		action :create
		recursive true
	end
	mount node['encryptfs']['mountpath'] do
		device "/dev/mapper/#{node['encryptfs']['name']}"
		fstype node['encryptfs']['fstype']
		action [ :mount, :enable ]
	end
	
else
	# This cookbook doesn't support other platforms.
end
