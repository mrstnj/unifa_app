class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :login, null: false
      t.string :password_hash, null: false
      t.string :password_salt, null: false
      t.string :access_token
      t.datetime :access_token_expire_date

      t.timestamps
    end
  end
end
