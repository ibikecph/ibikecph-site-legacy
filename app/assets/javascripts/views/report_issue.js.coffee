class IBikeCPH.Views.ReportIssue extends Backbone.View
	template: JST['report_issue']

	instructions: []

	events:
		'click .header .back'			: 'hide'
		'click .bug'					: 'step_2'
		'click .feedbackSubmit'			: 'submit_issue'

	initialize: (options) ->

	render: (waypoints, instructions) ->
		@$el.html @template()
		$('#ui').css
			left: 25
		$('#report').css
			height: $("#ui").outerHeight()+2
			left: 0
		$('#report #step_1.inner').css
			height: ($('#report').height()-$('#report .header').height())-40
		$('#report #step_2.inner').css
			height: ($('#report').height()-$('#report .header').height())-93
		this

	step_2: ->
		$('#step_1').hide()
		$('#step_2, .submits').show()
		$.each $("#instructions li .instruction_text"), ->
  			option = $("<option />").html($(@).text())
  			option.attr
  				'value': $(@).text()

  			$('#step_2 form select').append(option)

		$('#step_2 form select').customSelect('.selectReplace')
		$(".reportProblemForm input[type='radio']").bind "click", ->
			container = $(this).parent()
			explainProblem = $(".reportProblemForm .explainProblem")
			explainProblem.remove()  if explainProblem.length > 0
			container.append "<textarea name=\"message\" id=\"\" class=\"explainProblem\" placeholder=\"Uddyb evt. problemet...\"></textarea>"
			container.find("textarea").focus()


	hide: ->
		t = @
		$('#ui').css
			left: 0
		$('#report').css
			left: -390
		setTimeout ( ->
			t.unbind()
			t.remove()
			$('#viewport').append('<div id="report"></div>')
		), 500

	submit_issue: ->
		issue = new IBikeCPH.Models.ReportIssue
			issue:
				error_type: $('#report input:radio[name=route]:checked').val()
				comment: $('#report .explainProblem').val()
				route_segment: $('#report select').val()

		console.log issue

		issue.save()