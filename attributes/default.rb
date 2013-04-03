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

# If the last encryptfs is removed, setting this true will uninstall cryptsetup
default[:encryptfs][:uninstall_cryptsetup_iflast] = false

# Path to the cryptdisks_start and cryptdisks_stop files
default[:encryptfs][:cryptdisks_path] = "/sbin" unless node.platform?("ubuntu")
default[:encryptfs][:cryptdisks_path] = "/usr/sbin" if node.platform?("ubuntu")
default[:encryptfs][:cryptdisks_start] = "#{node[:encryptfs][:cryptdisks_path]}/cryptdisks_start"
default[:encryptfs][:cryptdisks_stop] = "#{node[:encryptfs][:cryptdisks_path]}/cryptdisks_stop"
