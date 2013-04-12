json.success "true"
json.info "User Details"
json.data do
    json.id @user.id
    json.name @user.name
    json.email @user.email
    json.about @user.about
    json.role @user.role
    json.image_url @profile_image_url
end