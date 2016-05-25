class IBikeCPH.Geocoder

  constructor: (@model) ->
    @model.on 'input:address', => @address_to_location()
    @model.on 'input:location', => @location_to_address()
    
  abort: ->
    if @request?
      @request.abort()
      @reqeust = null

  lookup_init: ->
    @abort()

  lookup_done: ->
    @request = null
    $('.from, .to').blur()

  address_to_location: ->
    address =  @model.get 'address'
    options = _.extend
      format : 'json'
      q      : "#{address}"
      limit  : '1'
    , IBikeCPH.config.geocoding_service.options
    @lookup_init()
    @request = $.getJSON IBikeCPH.config.geocoding_service.url + '?json_callback=?', options, (result) =>
      if result[0]
        location = lat: Number(result[0].lat), lng: Number(result[0].lon)
        # L.Map.panTo(Number(result[0].lat), Number(result[0].lon))
      else
        location = null
      @model.set 'location', location
      @lookup_done()
  
  location_to_address: ->
    @abort()
    return if @model.get('type') == 'via'
    location =  @model.get 'location'
    return unless location
    options = _.extend
      format : 'json'
      lat    : location.lat
      lon    : location.lng
    , IBikeCPH.config.geocoding_service.options
    @lookup_init()    
    @request = $.getJSON IBikeCPH.config.reverse_geocoding_service.url + '?json_callback=?', options, (result) =>
      address = IBikeCPH.util.displayable_address result
      @model.set 'address', address if address
      @lookup_done()
