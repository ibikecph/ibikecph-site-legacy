json.success "true"
json.info "Reported Issue Details"
json.data do
	json.(@reported_issue, :id, :user_id, :error_type, :comment)
end