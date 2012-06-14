class ibikecph.Router extends Backbone.Router

	routes:
		'!/*from/*to/*via': 'show_route'

	initialize: (options) ->
		@app = options.app

	show_route: (from, to, via) ->
		from = ibikecph.util.normalize_whitespace(decodeURIComponent(from or ''))
		to   = ibikecph.util.normalize_whitespace(decodeURIComponent(to   or ''))
		via  = ibikecph.util.normalize_whitespace(decodeURIComponent(via  or ''))

		console.log 'show_route from=[%s] to=[%s] via=[%s]', from, to, via

		@app.info.from.set 'address', from
		@app.info.to.set   'address', to
		@app.info.via.set  'address', via

	navigate_route: (from, via, to, replace) ->
		from = encodeURIComponent(ibikecph.util.normalize_whitespace(from or ''))
		to   = encodeURIComponent(ibikecph.util.normalize_whitespace(to   or ''))
		via  = encodeURIComponent(ibikecph.util.normalize_whitespace(via  or ''))

		fragment = '!/' + from + '/' + to + '/' + via

		@navigate fragment, (
			trigger: true
			replace: replace
		)
