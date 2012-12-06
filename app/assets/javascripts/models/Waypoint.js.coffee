# A waypoint (ie. from/to/via) that the user entered.

class IBikeCPH.Models.Waypoint extends Backbone.Model

	defaults:
		location: null
		located: false
		
	initialize: ->
		@set 'located', @get('location')?, silent: true
		new IBikeCPH.Geocoder this
		
		@on 'change:location', =>
			@set 'located', @get('location')?

		@on 'change:type', =>
			type = @get 'type'
			unless type == 'via'
				@trigger 'input:location' if @get 'location'
			
	located: ->
		@get('located' ) == true

	to_latlng: ->
		location = @get 'location'
		return null unless location and location?.lat? and location?.lng?

		lat = 1 * location.lat
		lng = 1 * location.lng

		if isNaN(lat) or isNaN(lng)
			null
		else
			new L.LatLng lat, lng

	reset: ->
		@set address: null, location: null

	to_code: ->
		location = @get 'location'

		lat = 1000000 * location.lat
		lng = 1000000 * location.lng
		return '' if isNaN(lat) and isNaN(lng)

		# String representation of this waypoint.
		return Math.floor(lat).toString(36) + '.' + Math.floor(lng).toString(36)

IBikeCPH.Models.Waypoint.from_code = (code) ->
	# Parse string representation to the location of a waypoint.
	location = "#{code}".match /^(-?[a-z0-9]{1,6})\.(-?[a-z0-9]{1,6})$/i

	waypoint = new IBikeCPH.Models.Waypoint

	if location
		setTimeout ->
			waypoint.set 'location', (
				lat: parseInt(location[1], 36) * 1e-6
				lng: parseInt(location[2], 36) * 1e-6
			)
		, 1

	return waypoint
