class AddRouteSegmentToReportedIssues < ActiveRecord::Migration
  def up
     add_column :reported_issues, :route_segment, :string  
  end

  def down
     remove_column :reported_issues, :route_segment
  end
end
