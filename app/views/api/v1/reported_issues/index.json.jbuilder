json.success "true"
json.info "Reported Issues"
json.data @reported_issues do |json, issue|
	json.(issue, :id, :user_id, :error_type, :comment)
end