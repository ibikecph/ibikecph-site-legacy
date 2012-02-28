# This program is free software you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# or see http://www.gnu.org/licenses/agpl.txt.

# OSRM EventHandler
# [adds simple event handling: other classes can derive from this class to acquire custom event handling]


OSRM.EventHandler = () ->
	@_listeners = {}

OSRM.extend( OSRM.EventHandler, 
	
# add listener
addListener: (type, listener) ->
	if @_listeners[type] == undefined
		@_listeners[type] = []
	@_listeners[type].push(listener)
,
# remove event listener
removeListener: (type, listener) ->
	if @_listeners[type] != undefined 
		for i in [0...@_listeners[type].length]
			if @_listeners[type][i] == listener 
				@_listeners[type].splice(i,1)
				break
,
# fire event
fire: (event) ->
	if typeof event == "string"
		event = type:event
	if !event.target 
		event.target = this
	
	if !event.type 
		throw new Error("event object missing type property!")
	
	if @_listeners[type] != undefined
		for i of @_listeners[event.type]
			listener.call(this, event)
)