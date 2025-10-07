class AddSharingToBuilds < ActiveRecord::Migration[8.0]
  def change
    add_column :builds, :share_token, :string
    add_column :builds, :shared_data, :text
    add_column :builds, :shared_at, :datetime
  end
end
