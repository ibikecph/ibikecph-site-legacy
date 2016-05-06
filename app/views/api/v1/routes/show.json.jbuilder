json.success "true"
json.info "Route Details"
json.data do
    json.id @route.id
    json.user_id @route.user_id
    json.fromName @route.from_name
    json.fromLattitude @route.from_latitude #should be mispelled in v1!
    json.fromLongitude @route.from_longitude
    json.toName @route.to_name
    json.toLattitude @route.to_latitude #should be mispelled in v1!
    json.toLongitude @route.to_longitude
    json.startDate @route.start_date? ? @route.start_date.strftime("%Y-%m-%dT%H:%M:%SZ%Z") : "null"
    #json.startDate @route.start_date
    json.endDate @route.end_date? ? @route.end_date.strftime("%Y-%m-%dT%H:%M:%SZ%Z") : "null"
    #json.endDate @route.end_date  
    json.visitedLocations @route.route_visited_locations
    json.finishedRoute @route.is_finished    
end