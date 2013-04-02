class ReportedIssue < ActiveRecord::Base
  attr_accessible :comment, :error_type, :is_open, :route_segment
  validates_presence_of :comment, :error_type, :route_segment
end
