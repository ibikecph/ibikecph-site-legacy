class CreateThemings < ActiveRecord::Migration[4.2]
  def change
    create_table :themings do |t|
      t.references :issue
      t.references :theme
      t.timestamps
    end
  end
end
