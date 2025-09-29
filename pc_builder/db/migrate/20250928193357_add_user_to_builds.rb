class AddUserToBuilds < ActiveRecord::Migration[7.1]
  def change
    if !column_exists?(:builds, :user_id)
      add_reference :builds, :user, null: true, foreign_key: true
    else
      # Column exists; make sure index + FK exist
      add_index :builds, :user_id unless index_exists?(:builds, :user_id)
      add_foreign_key :builds, :users unless foreign_key_exists?(:builds, :users)
      change_column_null :builds, :user_id, true
    end
  end
end
