json.success "true"
json.info "Route Details"
json.data do
    json.id @route.id
    json.user_id @route.user_id
    json.fromName @route.from_name
    json.fromLattitude @route.from_lattitude
    json.fromLongitude @route.from_longitude
    json.toName @route.to_name
    json.fromLattitude @route.to_lattitude
    json.fromLongitude @route.to_longitude
    json.startDate @route.start_date.strftime("%Y-%m-%dT%H:%M:%SZ%Z")
    json.endDate @route.end_date? ? @route.end_date.strftime("%Y-%m-%dT%H:%M:%SZ%Z") : "null"	
    json.visitedLocations @route.route_visited_locations
    json.finishedRoute @route.is_finished    
end