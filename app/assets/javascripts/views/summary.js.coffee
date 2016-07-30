class IBikeCPH.Views.Summary extends Backbone.View
  
  events:
    'click .details'               : 'details'
    
  initialize: (options) ->
    @router = options.router
    @model.on 'change', @render
    @model.on 'reset', @hide
    
  details: (event) =>
    $('#instructions_div').stop().slideToggle(250)

  show: ->
    @$el.show()

  hide: =>
    @$el.hide() if @$el
    $(".distance", @el).empty()
    $(".duration", @el).empty()
    if $current_user
      $('.search_bottom').hide()
  
  render: =>
    meters = @model.get 'total_distance'
    seconds = @model.get 'total_duration'
    if meters and seconds
      @abort_hide()
      @$el.show()
      if $current_user
        $('.search_bottom').show()
      $(".distance", @el).text( IBikeCPH.Views.Instruction.humanize_distance(meters) )
      $(".duration", @el).text( IBikeCPH.Views.Instruction.humanize_duration(seconds) )
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
  