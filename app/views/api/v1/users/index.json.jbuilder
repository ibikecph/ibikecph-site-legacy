json.success "true"
json.info "List Users"
json.data @users do |json, user|
	json.(user, :id, :name, :email, :about, :role)
end