class AddLockCountToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :lock_count, :integer, default: 0
    add_column :users, :unlock_time, :datetime
  end
end
