class CreateReportedIssues < ActiveRecord::Migration
  def change
    create_table :reported_issues do |t|
      t.string :route_segment
      t.string :error_type
      t.text :comment
      t.boolean :is_open, :default => true
      t.timestamps
    end
  end
end
