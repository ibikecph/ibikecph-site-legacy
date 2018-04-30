class CreateVotes < ActiveRecord::Migration[4.2]
  def change
    create_table :votes do |t|
      t.references :user
      t.references :issue
      t.timestamps
    end
  end
end
