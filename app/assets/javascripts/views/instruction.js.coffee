class IBikeCPH.Views.Instruction extends Backbone.View
	template: JST['instructions/instruction']
	tagName: 'li'
	
	events:
		'click': 'indicate'
	
	render: =>
		@$el.html @template(instruction: @model)
		this

	indicate: =>
		console.log @model.get 'street'
