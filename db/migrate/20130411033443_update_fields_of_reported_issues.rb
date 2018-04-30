class UpdateFieldsOfReportedIssues < ActiveRecord::Migration[4.2]
  def up
    add_column :reported_issues, :user_id, :integer, :null => true 
    remove_column :reported_issues, :route_segment 
  end

  def down
    remove_column :reported_issues, :user_id
    add_column :reported_issues, :route_segment, :string
  end
end
