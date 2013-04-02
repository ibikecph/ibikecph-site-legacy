json.success "true"
json.info "Reported Issues"
json.issues @reported_issues do |json, issue|
	json.(issue, :id, :route_segment, :error_type, :comment)
end