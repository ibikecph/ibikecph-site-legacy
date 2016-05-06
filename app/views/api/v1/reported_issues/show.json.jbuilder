json.success "true"
json.info "Reported Issue Details"
json.data do
  json.(@reported_issue, :id, :user_id, :route_segment, :error_type, :comment)
end