class IBikeCPH.Views.Instruction extends Backbone.View
	template: JST['instructions/instruction']
	tagName: 'li'
	
	events:
		'mouseenter': 'show'
	
	render: =>
		@$el.html @template(instruction: @model)
		this

	show: ->
		@model.trigger 'show_step', @model