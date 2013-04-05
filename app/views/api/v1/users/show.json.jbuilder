json.success "true"
json.info "User Details"
json.data do
	json.(@user, :id, :name, :email, :about, :role)
end