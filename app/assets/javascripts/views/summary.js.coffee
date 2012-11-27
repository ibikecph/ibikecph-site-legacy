class IBikeCPH.Views.Summary extends Backbone.View
	
	initialize: (options) ->
		Backbone.View.prototype.initialize.apply this, options
		@router = options.router
		@model.on 'change', @render
		
	show: ->
		@$el.show()

	hide: ->
		@$el.hide()

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
				@$el.hide()
				@timer = undefined
			
	abort_hide: ->
		if @timer
			clearTimeout @timer
			@timer = undefined
		
	wait_for: (milliseconds, callback) ->
		@abort_hide
		@timer = setTimeout callback, milliseconds
	