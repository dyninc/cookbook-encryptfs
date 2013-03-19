encryptfs "data" do
	size 100
	filepath "/cryptfs"
	mountpath "/usr/local/cryptdata"
	fstype "ext4"
	action :create
end
