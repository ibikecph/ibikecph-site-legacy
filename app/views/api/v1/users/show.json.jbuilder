json.success "true"
json.info "User Details"
json.data do
    json.id @user.id
    json.name @user.name
    json.email @user.email
    json.about @user.about
    json.role @user.role
    if @user.provider=="facebook" and @user.uid? and @user.uid!="" and !@user.image?
    	json.image_url "http://graph.facebook.com/"+@user.uid+"/picture?type=large"
    else
    	json.image_url @user.image? ? @user.image.g2.url : "null"
    end
end