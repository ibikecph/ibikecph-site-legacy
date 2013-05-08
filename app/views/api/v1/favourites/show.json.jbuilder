json.success "true"
json.info "Favourite Details"
json.data do
    json.id @favourite.id
    json.user_id @favourite.user_id
    json.name @favourite.name
    json.address @favourite.address
    json.lattitude @favourite.lattitude
    json.longitude @favourite.longitude
    json.source @favourite.source
    json.sub_source @favourite.sub_source
    json.startDate @favourite.created_at.strftime("%Y-%m-%dT%H:%M:%SZ%Z")
    json.endDate @favourite.created_at.strftime("%Y-%m-%dT%H:%M:%SZ%Z")
end