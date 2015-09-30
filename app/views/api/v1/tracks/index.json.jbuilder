json.success "true"
json.info "Tracks"
json.data @tracks do |track|
  json.id track.id
  json.from_name track.from_name
  json.to_name track.to_name
  json.timestamp track.timestamp
  json.coordinates track.coordinates
end