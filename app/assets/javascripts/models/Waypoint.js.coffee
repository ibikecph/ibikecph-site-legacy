# A waypoint (ie. from/to/via) that the user entered.

class ibikecph.Waypoint extends Backbone.Model

	defaults:
		type: 'via'
		address: ''
		location:
			lat: null
			lng: null
		loading: false

	initialize: ->
		new ibikecph.Geocoder this

	clear: ->
		@set
			address: ''
			location:
				lat: null
				lng: null
			loading: false

	to_code: ->
		location = @get 'location'

		lat = 100000 * location.lat
		lng = 100000 * location.lng
		return '' if isNaN(lat) and isNaN(lng)

		# String representation of this waypoint.
		return Math.floor(lat).toString(36) + '.' + Math.floor(lng).toString(36)

ibikecph.Waypoint.from_code = (code) ->
	# Parse string representation to the location of a waypoint.
	location = "#{code}".match /^(-?[a-z0-9]{1,5})\.(-?[a-z0-9]{1,5})$/i

	waypoint = new ibikecph.Waypoint

	if location
		setTimeout ->
			waypoint.set 'location', (
				lat: parseInt(location[1], 36) * 1e-5
				lng: parseInt(location[2], 36) * 1e-5
			)
		, 1

	return waypoint
