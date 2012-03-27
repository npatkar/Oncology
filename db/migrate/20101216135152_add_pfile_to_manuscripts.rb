class AddPfileToManuscripts < ActiveRecord::Migration
  def self.up
    add_column :manuscripts, :pfile_file_name, :string
    add_column :manuscripts, :pfile_content_type, :string # Mime type
    add_column :manuscripts, :pfile_file_size, :integer # File size in bytes
  end

  def self.down
    remove_column :manuscripts, :pfile_file_name
    remove_column :manuscripts, :pfile_content_type
    remove_column :manuscripts, :pfile_file_size
  end
end
