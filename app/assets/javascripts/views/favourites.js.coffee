class IBikeCPH.Views.Favourites extends Backbone.View
	template: JST['favourites']

	events:
		'click .header .back'			: 'hide'
		'click .routes li'				: 'select_address'
		'click .types li'				: 'select_source'
		'keyup .favorite_name'			: 'select_name'
		'click .save button'			: 'save_favourite'

	data:
		name: ''
		address: ''
		lattitude: ''
		longitude: ''
		source: ''
		sub_source: ''

	initialize: (options) ->


	render: (waypoints) ->
		@$el.html @template()

		from = waypoints.first().toJSON()
		to = waypoints.last().toJSON()

		$('#favorites b.start').html(from.address).attr
			'data-address': from.address
			'data-lat': from.location.lat
			'data-lng': from.location.lng
		$('#favorites b.dest').html(to.address).attr
			'data-address': to.address
			'data-lat': to.location.lat
			'data-lng': to.location.lng

		@data.address = from.address
		@data.lattitude = from.location.lat
		@data.longitude = from.location.lng
		@data.source = 'favorite'
		@data.sub_source = 'favorite'

		$('#favorites .favorite_name').focus()
		
		unless from.name == ''
			$('#favorites .favorite_name').val(from.name)

		$('#ui').css
			left: 25
		$("#favorites").css
			height: $("#ui").outerHeight()+2
			left: 0
		this
	

	select_address: (event) ->
		el = $(event.currentTarget)
		input = el.find('b')

		unless el.hasClass('selected')
			$('.routes .selected').removeClass('selected')
			el.addClass('selected')
			@data.address = input.data('address')
			@data.lattitude = input.data('lat')
			@data.longitude = input.attr('data-lng')

		return false

	select_source: (event) ->
		el = $(event.currentTarget)

		unless el.hasClass('selected')
			$('.types .selected').removeClass('selected')
			el.addClass('selected')
			@data.source = el.data('category')

	select_name: (event) ->
		el = $(event.currentTarget)
		@data.name = el.val()

	save_favourite: ->
		fav = new IBikeCPH.Models.Favourites
			favourite:
				name: @data.name
				address: @data.address
				lattitude: @data.lattitude
				longitude: @data.longitude
				source: @data.source
				sub_source: @data.sub_source
			
		fav.save null,
			success: (model, response) ->
				$('#favorites .form').hide()
				$('#favorites .success').show()
			error: (model, response) ->
				$('#favorites .errors').html('')
				_.each JSON.parse(response.responseText).errors, (t,num) ->
					$('#favorites .errors').append('<li>'+t+'</li>')


	hide: ->
		t = @
		$('#ui').css
			left: 0
		$("#favorites").css
			left: -390
		setTimeout ( ->
			t.unbind()
			t.remove()
			$('#viewport').append('<div id="favorites"></div>');
		), 500