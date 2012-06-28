class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.references :user
      t.string   :title
      t.text     :body
      t.string   :status
      t.integer  :comments_count, :default => 0
      t.integer  :votes_count, :default => 0
      t.timestamps
    end
  end
end
