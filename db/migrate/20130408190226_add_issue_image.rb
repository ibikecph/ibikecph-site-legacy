class AddIssueImage < ActiveRecord::Migration[4.2]
    def change
      add_column :issues, :image, :string    
    end
end
