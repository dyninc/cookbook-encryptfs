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
