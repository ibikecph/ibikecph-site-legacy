class ibikecph.Geocoder

	constructor: (@model) ->
		@current =
			address: null
			location:
				lat: null
				lng: null

		@request = null

		@model.bind 'change:address', =>
			@load_address @model.get 'address'

		@model.bind 'change:location', =>
			@abort()
			@wait_for 300, =>
				@load_location @model.get 'location'

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

		return unless @current.address

		@request_init()

		@request = $.getJSON 'http://nominatim.openstreetmap.org/search?json_callback=?', (
			format            : 'json'
			'accept-language' : 'da'
			q                 : "#{@current.address}"
			countrycodes      : 'DK'
			viewbox           : '-27.0,72.0,46.0,36.0'
			bounded           : '1'
			email             : 'info@contingent.dk'
			limit             : '1'
		), (result) =>
			@request_done()

			@current.location.lat = @convert_number result[0]?.lat
			@current.location.lng = @convert_number result[0]?.lon
			@model.set @current

	load_location: (new_location) ->
		return if new_location?.lat == @current.location.lat and new_location?.lng == @current.location.lng

		@current.location.lat = new_location?.lat
		@current.location.lng = new_location?.lng

		return unless @current.location.lat and @current.location.lng

		@request_init()

		@request = $.getJSON 'http://nominatim.openstreetmap.org/reverse?json_callback=?', (
			format            : 'json'
			'accept-language' : 'da'
			lat               : @current.location.lat or 0
			lon               : @current.location.lng or 0
			addressdetails    : '1'
			email             : 'info@contingent.dk'
		), (result) =>
			@request_done()

			address = result?.address
			if address and address.road and address.postcode and address.city
				@current.address = "#{address.road}#{[' ' + address.house_number if address.house_number]}, #{address.postcode} #{address.city}"

			@current.location.lat = @convert_number result?.lat
			@current.location.lng = @convert_number result?.lon
			@model.set @current
