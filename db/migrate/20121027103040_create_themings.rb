class CreateThemings < ActiveRecord::Migration
  def change
    create_table :themings do |t|
      t.references :issue
      t.references :theme
      t.timestamps
    end
  end
end
