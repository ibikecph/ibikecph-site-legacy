class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.references :user
      t.string :provider, :null => false
      t.string :uid, :null => false
      t.string :type
      t.string :state
      t.string :token
      t.datetime :token_created_at
      t.datetime :activated_at
      t.timestamps
    end
  end
end
