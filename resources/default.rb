actions :create, :delete
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :size, :kind_of => Fixnum, :default => 100
attribute :filepath, :kind_of => String, :required => true
attribute :mountpath, :kind_of => String, :required => true
attribute :fstype, :kind_of => String, :default => 'ext4'

attr_accessor :exists
