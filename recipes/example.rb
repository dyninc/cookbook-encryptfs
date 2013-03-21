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

encryptfs "data" do
  size 100
  filepath "/cryptfs"
  mountpath "/usr/local/cryptdata"
  fstype "ext4"
  action :create
end

encryptfs "data2" do
  size 100
  filepath "/cryptfs2"
  mountpath "/usr/local/cryptdata2"
  fstype "ext4"
  action :create
end

encryptfs "data3" do
  size 100
  filepath "/cryptfs3"
  mountpath "/usr/local/cryptdata3"
  fstype "ext4"
  action :create
end
