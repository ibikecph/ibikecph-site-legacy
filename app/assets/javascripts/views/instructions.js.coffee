class IBikeCPH.Views.Instructions extends Backbone.View
	template: JST['instructions/index']
		
	initialize: ->
		@collection.on 'reset', @clear
		@collection.on 'change', @render
	
	clear: =>
		@$el.empty()
		
	render: =>
		@$el.html @template()
		@collection.each @appendInstruction
		this

	appendInstruction: (instruction) =>
		view = new IBikeCPH.Views.Instruction model: instruction
		@$('#instructions').append view.render().el