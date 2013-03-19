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
	@current_resource = Chef::Resource::Encryptfs.new(@new_resource.name)
	@current_resource.name(@new_resource.name)
	@current_resource.mountpath(new_resource.mountpath)
	if encryptfs_exists?(@current_resource.name)
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
		notifies :run, "execute[reload-crypttab]", :immediately
	end
	
	# reload crypttab
	execute "reload-crypttab" do
		command "/etc/init.d/cryptdisks reload"
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

	# FIXME: Should I remove the cryptsetup package if crypttab is now empty?
end

def encryptfs_exists?(name)
	return system("/sbin/cryptsetup status #{name}")
end

def encryptfs_crypttab_exists?(name)
	return false if (! ::File.exists?( "/etc/crypttab" ))
	::File.foreach("/etc/crypttab") do |line|
		return true if ( line =~ /^#{name} /o )
	end
	Chef::Log.info("#{name} not found in crypttab")
	return false
end

def encryptfs_crypttab_add(name, filepath, fstype)
	newline = "#{name} \t#{filepath}\t /dev/urandom \ttmp=#{fstype},cipher=aes-cbc-essiv:sha256,noearly\n"
	::File.open("/etc/crypttab", "a") do |crypttab|
		crypttab.puts(newline)
	end
end

def encryptfs_crypttab_delete(name)
	contents = []
	::File.readlines("/etc/crypttab").reverse_each do |line|
		if (!(line =~ /^#{name} /o ))
			contents << line
		else
			Chef::Log.info("#{@new_resource} is removed from crypttab")
		end
	end
	
	::File.open("/etc/crypttab", "w") do |crypttab|
		contents.reverse_each { |line| crypttab.puts line }
	end
end

