json.success "true"
json.info "Reported Issues"
json.data @reported_issues do |issue|
	json.(issue, :id, :user_id, :route_segment, :error_type, :comment)
end
