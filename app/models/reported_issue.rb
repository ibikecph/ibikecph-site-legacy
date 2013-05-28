class ReportedIssue < ActiveRecord::Base
  attr_accessible :route_segment, :comment, :error_type, :is_open
  validates_presence_of :comment, :error_type
  belongs_to :user
end
