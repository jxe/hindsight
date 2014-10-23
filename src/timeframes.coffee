class window.Timeframe
	constructor: (@str) ->
	isActive: ->
		!@str or @str.match(/^\d+-$/) or @str.match(/^on [\d\.]+$/)
	off: ->
		utc = Date.now() / 1000
		return @str unless @isActive()
		return "not on #{utc}" if !@str
		return "#{@str}, not on #{utc}" if @str.match(/^on [\d\.]+$/)
		return "#{@str}#{utc}" if @str.match(/^[\d\.]+-$/)
	on: ->
		utc = Date.now() / 1000
		return "on #{utc}" if !@str or @str.match(/not/) or @str.match(/^[\d\.]+-[\d\.]+$/)
		return @str if @isActive()
		return "on #{utc}"
	set: (value) ->
		if value then @on() else @off()
	@set: (ref, value) ->
		ref.transaction (data) -> new Timeframe(data).set(value)
