class CreateFollows < ActiveRecord::Migration[4.2]
  def change
    create_table :follows do |t|
      t.references  :user
      t.references  :followable, :polymorphic => true
      t.boolean  :active, :default => true
      t.timestamps
    end
  end
end
