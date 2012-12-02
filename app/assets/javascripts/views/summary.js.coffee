class IBikeCPH.Views.Summary extends Backbone.View
	
	events:
		'click .details'	             : 'details'
		
	initialize: (options) ->
		Backbone.View.prototype.initialize.apply this, options
		@router = options.router
		@model.on 'change', @render
		@model.on 'reset', @hide
		
	details: (event) =>
		$('#instructions_div').toggle()

	show: ->
		@$el.show()

	hide: =>
		@$el.hide() if @$el
		$(".distance", @el).empty()
		$(".duration", @el).empty()
	
	render: =>
		meters = @model.get 'total_distance'
		seconds  = @model.get 'total_time'
		if meters and seconds
			@abort_hide()
			@$el.show()
			if meters>=1000
				$(".distance", @el).text((meters/1000).toFixed(2) + ' km')
			else
				$(".distance", @el).text(meters + ' m')
				
			if seconds>=60
				$(".duration", @el).text(Math.floor(seconds/60.0) + ' min')
			else
				$(".duration", @el).text(seconds + ' sek')
		else
			@hide_in 200		
		this
	
	hide_in: (milliseconds) ->
		unless @timer
			@wait_for milliseconds, =>
				@hide()
				@timer = undefined
			
	abort_hide: ->
		if @timer
			clearTimeout @timer
			@timer = undefined
		
	wait_for: (milliseconds, callback) ->
		@abort_hide
		@timer = setTimeout callback, milliseconds
	