window.ibikecph or= {}

window.ibikecph.Point = Backbone.Model.extend

	defaults:
		address : ''
		lat     : null
		lng     : null
		loading : false

	initialize: ->
		@current_coder   = null
		@silent_address  = false
		@silent_location = false

		@bind 'change:address', =>
			@load_address @get('address')

		@bind 'change:lat change:lng', =>
			@load_location
				lat: @get 'lat'
				lng: @get 'lng'

	load_address: (address) ->
		return if @silent_address or not address

		@cancel_coder()

		do =>
			canceled = false

			@set 'loading', true

			@geocode address, (location) =>
				return if canceled

				@set 'loading', false
				@silent_location = true
				@set location
				@silent_location = false

			@current_coder = ->
				canceled = true

	load_location: (location) ->
		return if @silent_location or not location.lat or not location.lng

		@cancel_coder()

		do =>
			canceled = false

			@set 'loading', true

			@reverse_geocode location, (result) =>
				return if canceled

				@set 'loading', false
				@silent_address = true
				@set result
				@silent_address = false

			@current_coder = ->
				canceled = true

	cancel_coder: =>
		if typeof(@current_coder) == 'function'
			@current_coder()
			@current_coder = null
			@set 'loading', false

	geocode: (address, callback) ->
		$.getJSON 'http://nominatim.openstreetmap.org/search?json_callback=?', (
			format            : 'json'
			'accept-language' : 'da'
			q                 : "#{[address]}"
			countrycodes      : 'DK'
			viewbox           : '-27.0,72.0,46.0,36.0'
			bounded           : '1'
			email             : 'info@contingent.dk'
			limit             : '1'
		), (result) ->
			callback (
				lat: result[0]?.lat
				lng: result[0]?.lon
			)

	reverse_geocode: (location, callback) ->
		$.getJSON 'http://nominatim.openstreetmap.org/reverse?json_callback=?', (
			format            : 'json'
			'accept-language' : 'da'
			lat               : location.lat or 0
			lon               : location.lng or 0
			addressdetails    : '1'
			email             : 'info@contingent.dk'
		), (result) ->
			callback (
				lat: result[0]?.lat
				lng: result[0]?.lon
			)
