class ibikecph.InstructionsSummary extends Backbone.Model
	initialize: -> 
		self = this
		#fake change event every minute, to update time
		setInterval ->
			self.trigger('change')
		, 1000 * 60
