# A waypoint (ie. from/to/via) that the user entered.

class IBikeCPH.Models.Waypoint extends Backbone.Model

  defaults:
    location: null
    located: false
    
  initialize: ->
    @precision = precision = IBikeCPH.config.routing_service.precision
    @set 'located', @get('location')?, silent: true
    new IBikeCPH.Geocoder this
    
    @on 'change:location', =>
      @set 'located', @get('location')?

    @on 'change:type', =>
      type = @get 'type'
      unless type == 'via'
        @trigger 'input:location' if @get 'location'
      
  located: ->
    @get('located' ) == true

  to_latlng: ->
    location = @get 'location'
    return null unless location
    new L.LatLng location.lat, location.lng

  reset: ->
    @set address: null, location: null

  # note: for links, we use the old precison of 6 decimals, even though
  # osrm v5 now uses 5 decimals. this is to support old links
  
  to_str: ->
    #string representation, used in url's
    location = @get 'location'
    return '' unless location
    lat = Math.floor(location.lat / 1e-6)
    lng = Math.floor(location.lng / 1e-6)
    str = lat.toString(36) + '.' + lng.toString(36)
    return str 

  from_str: (str) ->
    location = "#{str}".match /^(-?[a-z0-9]{1,6})\.(-?[a-z0-9]{1,6})$/i
    if location
      @set 'location',
          lat: parseInt(location[1], 36) * 1e-6
          lng: parseInt(location[2], 36) * 1e-6
      return

    console.log(str)
    location = "#{str}".match /^([0-9\.]+),([0-9\.]+)$/i
    if location
      @set 'location',
          lat: parseFloat(location[1])
          lng: parseFloat(location[2])
      return