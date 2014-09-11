values = (obj) ->
  return [] if !obj
  Object.keys(obj).map( (x) ->
    obj[x].id = x; return obj[x];
  )

class window.ReasonPicker extends Typeahead
  @content: (options) ->
    super(hint:options.hint)
  initialize: (options) ->
    { @type, @delegate, @hint, @thing } = options
    @thing ||= 'Value'
    @options = []
    
    @sub fb('values'), 'value', (snap) =>
      @options = values(snap.val()).filter (entry) =>
        return true unless @type
        return entry.id.match(///^#{@type}///)
    
    super
      hint: @hint
      suggestions: (q) =>
        return @options unless q
        return @options.filter (x) ->
          return x.name && x.name.toLowerCase().indexOf(q) >= 0
      onchoose: (data) => 
        @delegate ||= @parentView
        @delegate["onChose#{@thing}"].call(@delegate, Value.fromId(data.id))
      renderer: (obj) ->
        return "Add #{obj.name}" if obj.adder
        return Value.fromId(obj.id).lozenge('well')
      onadded: (str) =>
        @delegate ||= @parentView
        return @delegate["onAdded#{@thing}"].call(@delegate, str) if @delegate["onAdded#{@thing}"]
        
        if Resource.isUrl(str)
          Resource.fromUrl str, (r) =>
            @delegate["onChose#{@thing}"].call(@delegate, r.asEngagement())
        else
          v = @type && Value.create(@type, str)
          @pushPage new ReasonEditor(
            v, 
            ((v) => @delegate["onChose#{@thing}"].call(@delegate, v)),
            str
          )
