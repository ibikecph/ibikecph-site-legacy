class IBikeCPH.Views.Instruction extends Backbone.View
	template: JST['instructions/instruction']
	tagName: 'li'
	
	events:
		'mouseenter': 'show'
		'click': 'zoom'
	
	render: =>
		@$el.html @template(instruction: @model)
		this

	show: ->
		@model.trigger 'show_step', @model
		
	zoom: ->
		@model.trigger 'zoom_to_step', @model