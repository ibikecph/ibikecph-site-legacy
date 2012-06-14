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
		$.getJSON '/api/geocode', q: address, (data) ->
			callback(data)

	reverse_geocode: (location, callback) ->
		$.getJSON '/api/reverse-geocode', location, (data) ->
			callback(data)
