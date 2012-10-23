class CreateThemes < ActiveRecord::Migration
  def change
    create_table :themes do |t|
      t.references :user
      t.string   :title
      t.text     :body
      t.integer  :sticky
      t.string   :image
      t.timestamps
    end
  end
end
