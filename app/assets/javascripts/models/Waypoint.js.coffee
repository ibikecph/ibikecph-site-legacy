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
		return null unless location
		new L.LatLng location.lat, location.lng

	reset: ->
		@set address: null, location: null

	to_str: ->
		#string representation, used in url's
		location = @get 'location'
		return '' unless location
		lat = Math.floor(1e6 * location.lat)
		lng = Math.floor(1e6 * location.lng)
		return lat.toString(36) + '.' + lng.toString(36)

	from_str: (code) ->
		location = "#{code}".match /^(-?[a-z0-9]{1,6})\.(-?[a-z0-9]{1,6})$/i
		if location
			@set 'location',
					lat: parseInt(location[1], 36) * 1e-6
					lng: parseInt(location[2], 36) * 1e-6