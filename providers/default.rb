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
	end
end

action :delete do
	if @current_resource.exists
		converge_by("Delete #{ @new_resource }") do
			delete_encryptfs
		end
	else
		Chef::Log.info "#{ @current_resource } doesn't exist - can't delete."
	end
end


def load_current_resource
	@current_resource = Chef::Resource::encryptfs.new(@new_resource.name)
	@current_resource.mountpath(new_resource.mountpath)
#	check = `mount|grep 'on #{new_resource.mountpath} type'`
	if encryptfs_exists?(@current_resource.mountpath)
		# If there's already a crypt mount at path, populate it with variables
#		@current_resource.name(`mount|grep 'on #{new_resource.mountpath} type'|cut -f1 -d' '|sed 's#/dev/mapper/##'`)
#		@current_resource.filepath(`grep '^#{current_resource.name} ' /etc/crypttab|awk '{ print $2 }'`)
#		fstats = ::File:stat(current_resource.filepath)
#		@current_resource.size(fstats.size/1024/1024)
#		@current_resource.fspath(`mount|grep '^#{new_resource.path} '|cut -f5 -d' '`)
		@current_resource.exists = true
	end
end		


def create_encryptfs
	# Install cryptsetup
	package "cryptsetup" do
		action [ :install, :upgrade ]
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

	# create entry in /etc/crypttab (FIXME only supports a single crypttab entry)
	file "/etc/crypttab" do
		owner "root"
		group "root"
		mode "0644"
		content "#{new_resources.name} #{new_resource.filepath} /dev/urandom tmp=#{new_resources.fstype},cipher=aes-cbc-essiv:sha256,noearly"
		action :create
		notifies :run, "execute[reload-crypttab]", :immediately
	end
	
	# reload crypttab
	execute "reload-crypttab" do
		command "/etc/init.d/cryptdisks reload"
		action :nothing
	end
	
	# create and mount entry in fstab
	mount @new_resource.mountpath do
		device "/dev/mapper/#{new_resource.name}"
		fstype @new_resource.fstype
		action [ :mount, :enable ]
	end
end

def delete_encryptfs
	# Unmount and remove entry from fstab
	mount @new_resource.mountpath do
		device "/dev/mapper/#{new_resource.name}"
		fstype @new_resource.fstype
		action [ :unmount, :disable ]
	end

	# delete mount point
	directory @new_resource.mountpath do
		action :delete
	end
	
	# deactivate encrypted filesystem
	execute "remove-encryptfs" do
		command "/sbin/cryptsetup remove #{new_resources.name}"       
		action :run      
	end
	
	# FIXME (need to remove entry from /etc/crypttab
	
	# delete file for loop block device
	file @new_resource.filepath do
		action :delete
	end	

	# FIXME: Should I remove the cryptsetup package if crypttab is now empty?
end

def encryptfs_exists?
	return system("/sbin/cryptsetup status #{new_resource.name}")
end