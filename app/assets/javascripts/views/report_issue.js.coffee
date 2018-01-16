class IBikeCPH.Views.ReportIssue extends Backbone.View
  template: JST['report_issue']

  instructions: []

  events:
    'click .header .back'      : 'hide'
    'click .feedbackSubmit'      : 'submit_issue'

  initialize: (options) ->

  render: (waypoints, instructions) ->
    @$el.html @template()
    $('#ui').css
      left: 25
    $('#report').css
      height: $("#ui").outerHeight()+2
      left: 0
    $('#report #step_2.inner').css
      height: ($('#report').height()-$('#report .header').height())-93

    $('#step_2, .submits').show()
    $.each $("#instructions li .instruction_text"), ->
        option = $("<option />").html($(@).text())
        option.attr
          'value': $(@).text()
        $('#step_2 form select').append(option)

    $('#step_2 form select').customSelect('.selectReplace')
    this

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