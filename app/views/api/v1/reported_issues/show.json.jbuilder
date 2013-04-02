json.success "true"
json.info "Reported Issue Details"
json.(@reported_issue, :id, :route_segment, :error_type, :comment)
