class window.ResourcePicker extends Firecomplete
  @content: (options) ->
    options.hint ||= 'Search for apps or urls'
    super(hint:options.hint)
    
  initialize: (options) ->
    { @type, @delegate, @hint, @thing } = options
    @thing ||= 'Resource'
    
    super
      hint: @hint
      fb: fb('resources')     
      onchoose: (data) => 
        @delegate ||= @parentView
        @delegate["onChose#{@thing}"].call(@delegate, Resource.fromFirebaseObject(data))
      renderer: (obj) ->
        return "Add #{obj.name}" if obj.adder
        return Reason.fromId(obj.id).lozenge('well')
      onadded: (str) =>
        @delegate ||= @parentView
        return @delegate["onAdded#{@thing}"].call(@delegate, str) if @delegate["onAdded#{@thing}"]
        Resource.fromUrl str, (r) =>
          @delegate["onChose#{@thing}"].call(@delegate, r)
