# Modelled after L.Control.Zoom which source code can be seen at:
# https://github.com/CloudMade/Leaflet/blob/master/src/control/Control.Zoom.js

# The user of this control should implement the methods `.go_to_my_location()`
# and `.go_to_route()`. Example:
#
#     goto = new L.Control.Goto
#     goto.go_to_my_location = -> console.log 'My Location'
#     goto.go_to_route       = -> console.log 'Route'
#     map.addControl goto

L.Control.Goto = L.Control.extend

	options:
		position: 'topleft'

	onAdd: (map) ->
		class_name = 'leaflet-control-goto'
		container  = L.DomUtil.create 'div', class_name

		@_createButton 'Go to my location', "#{class_name}-my-location", container, => @go_to_my_location()
		@_createButton 'Go to route'      , "#{class_name}-route"      , container, => @go_to_route()

		container

	_createButton: (title, class_name, container, fn) ->
		link = L.DomUtil.create 'a', class_name, container
		link.href  = '#'
		link.title = title

		L.DomEvent
			.addListener(link, 'click', L.DomEvent.stopPropagation)
			.addListener(link, 'click', L.DomEvent.preventDefault)
			.addListener(link, 'click', fn)

		link
