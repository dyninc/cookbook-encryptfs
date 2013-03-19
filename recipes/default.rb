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

	encryptfs "data" do
		size "100"
		filepath "/cryptfs"
		mountpath "/usr/local/cryptdata"
		fstype "ext4"
		action :create
	end
	
else
	# This cookbook doesn't support other platforms.
end
