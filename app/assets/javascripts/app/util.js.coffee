window.ibikecph or= {}
window.ibikecph.util or= {}

window.ibikecph.util.normalize_whitespace = (text) ->
	"#{text}".replace(/^\s+|\s+$/g, '').replace(/\s+/g, ' ')
