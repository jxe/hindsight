class window.ReasonPicker extends Firecomplete
  @content: (options) ->
    super(hint:options.hint)
  initialize: (options) ->
    { @type, @delegate, @hint, @thing } = options
    @thing ||= 'Reason'
    
    super
      hint: @hint
      fb: fb('values')
      filter: (entry) =>
        return true unless @type
        return entry.id.match(///^#{@type}///)        
      onchoose: (data) => 
        @delegate ||= @parentView
        @delegate["onChose#{@thing}"].call(@delegate, Value.fromId(data.id))
      renderer: (obj) ->
        return "Add #{obj.name}" if obj.adder
        return Value.fromId(obj.id).lozenge('well')
      onadded: (str) =>
        @delegate ||= @parentView
        return @delegate["onAdded#{@thing}"].call(@delegate, str) if @delegate["onAdded#{@thing}"]
        v = @type && Value.create(@type, str)
        @pushPage new ReasonEditor(
          v, 
          ((v) => @delegate["onChose#{@thing}"].call(@delegate, v)),
          str
        )
