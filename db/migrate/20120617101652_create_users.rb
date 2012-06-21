class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.text :about
      t.string :image
      t.string :auth_token
      t.string :password_hash
      t.string :password_salt
      t.string :password_reset_token
      t.datetime :password_reset_sent_at
      t.datetime :remember_me_token_saved_at
      t.timestamps
    end
  end
end
