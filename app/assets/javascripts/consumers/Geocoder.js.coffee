class ibikecph.Geocoder

	constructor: (@model) ->
		@current =
			address : null
			lat     : null
			lng     : null

		@request = null

		@model.bind 'change:address', (model, new_address) =>
			@load_address @model.get 'address'

		@model.bind 'change:lat change:lng', =>
			@abort()
			@wait_for 300, =>
				@load_location
					lat: @model.get 'lat'
					lng: @model.get 'lng'

	wait_for: (milliseconds, callback) ->
		clearTimeout(@timer) if @timer
		@timer = setTimeout callback, milliseconds

	abort: ->
		@request.abort() if @request?.abort

	request_init: ->
		@abort()
		@model.set 'loading', true

	request_done: ->
		@request = null
		@model.set 'loading', false

	convert_number: (value) ->
		value = 1 * value
		if isNaN value
			null
		else
			value

	load_address: (new_address) ->
		return if new_address == @current.address
		@current.address = new_address

		@request_init()

		@request = $.getJSON 'http://nominatim.openstreetmap.org/search?json_callback=?', (
			format            : 'json'
			'accept-language' : 'da'
			q                 : "#{[new_address]}"
			countrycodes      : 'DK'
			viewbox           : '-27.0,72.0,46.0,36.0'
			bounded           : '1'
			email             : 'info@contingent.dk'
			limit             : '1'
		), (result) =>
			@request_done()

			@current.lat = @convert_number result[0]?.lat
			@current.lng = @convert_number result[0]?.lon
			@model.set @current

	load_location: (new_location) ->
		return if new_location.lat == @current.lat and new_location.lng == @current.lng
		@current.lat = new_location.lat
		@current.lng = new_location.lng

		@request_init()

		@request = $.getJSON 'http://nominatim.openstreetmap.org/reverse?json_callback=?', (
			format            : 'json'
			'accept-language' : 'da'
			lat               : new_location.lat or 0
			lon               : new_location.lng or 0
			addressdetails    : '1'
			email             : 'info@contingent.dk'
		), (result) =>
			@request_done()

			address = result?.address
			if address and address.road and address.postcode and address.city
				@current.address = "#{address.road}#{[' ' + address.house_number if address.house_number]}, #{address.postcode} #{address.city}"

			@current.lat = @convert_number result?.lat
			@current.lng = @convert_number result?.lon
			@model.set @current
