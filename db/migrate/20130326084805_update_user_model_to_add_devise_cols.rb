class UpdateUserModelToAddDeviseCols < ActiveRecord::Migration
  def up
    # Database authenticatable
    rename_column :users, "password_hash", "encrypted_password"
    change_column :users, "encrypted_password", :string, :limit => 128, :default => "", :null => false

    # Encryptable
    change_column :users, "password_salt", :string, :default => "", :null => false

    #Recoverable
    rename_column :users, "password_reset_token", "reset_password_token"
    rename_column :users, "password_reset_sent_at", "reset_password_sent_at"
    
    #Rememberable 
    rename_column :users, "remember_me_token_saved_at", "remember_created_at"
    
    #Token Authenticatable
    rename_column :users, "auth_token", "authentication_token"
  end

  def down
    # Database authenticatable
    rename_column :users, "encrypted_password", "password_hash"
    change_column :users, "password_hash", :string

    # Encryptable
    change_column :users, "password_salt", :string

    #Recoverable
    rename_column :users, "reset_password_token", "password_reset_token"
    rename_column :users, "reset_password_sent_at", "password_reset_sent_at"
    
    #Rememberable 
    rename_column :users, "remember_created_at", "remember_me_token_saved_at" 
    
    #Token Authenticatable
    rename_column :users, "authentication_token", "auth_token"
        
  end
end
