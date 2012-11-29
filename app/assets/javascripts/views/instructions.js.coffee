class IBikeCPH.Views.Instructions extends Backbone.View
	template: JST['instructions/index']
		
	#initialize: ->
	#	@collection.on 'reload', @render

	render: =>
		$(@el).html @template()
		@collection.each @appendInstruction
		this

	appendInstruction: (instruction) =>
		view = new IBikeCPH.Views.Instruction model: instruction
		@$('#instructions').append view.render().el