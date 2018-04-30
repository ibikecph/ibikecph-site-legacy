class CreateComments < ActiveRecord::Migration[4.2]
  def change
    create_table :comments do |t|
      t.references  :user
      t.references  :commentable, :polymorphic => true
      t.string   :title
      t.text     :body
      t.timestamps
    end
  end
end
