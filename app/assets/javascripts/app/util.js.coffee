ibikecph.util or= {}

ibikecph.util.normalize_whitespace = (text) ->
	"#{text}".replace(/^\s+|\s+$/g, '').replace(/\s+/g, ' ')
