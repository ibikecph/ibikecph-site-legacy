class ReportedIssue < ActiveRecord::Base
  attr_accessible :comment, :error_type, :is_open
  validates_presence_of :comment, :error_type
end
