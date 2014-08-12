class window.ReasonEditor extends Page
  initialize: (v, @cb, @name) ->
    @observe(@value = v, 'onReasonChanged')
    @configure()
  
  configure: =>
    @full_or_empty 'value', !!@value
    @full_or_empty 'aliases', @aliases?.length
    
    return unless v = @value
    @hypernymPicker.type = v.type
    @synonymPicker.type  = v.type
    
    @find('.ancestry').html(
      if v.isRoot()
        "#{v.lozenge()} is a good thing"
      else if @hypernym
        @find('.add-hyp').hide()
        "#{v.lozenge()} is a kind of #{@hypernym.lozenge()}"
      else 
        v.lozenge()
    )
    
    @find('.aliases').html @aliases.join(', ') if @aliases
    
    @find('.add_requirements').empty()
    for x in @value.requirementTypes
      @find('.add_requirements').append \
        new ReasonPicker(hint: "Add an #{x}", thing: "Requirement", type: x, delegate: this)
  
  @content: (value, cb, name) ->
    @div class: 'reason_editor', =>
      @header class: 'bar bar-nav', =>
        @a class: 'icon icon-left-nav pull-left', click: 'back'
      @div class: 'content', =>
        @div class: 'no_value content-padded', =>
          @h4 class: 'prompt', 
            @raw "What kind of thing is <b>#{name}</b>?"
          for type, desc of Reason.types()
            @button class: 'btn btn-block', set: type, click: 'set_type', =>
              @raw desc

        @div class: 'has_value content-padded', =>
          @p click: 'viewReason', =>
            @span class: 'ancestry'
            @a class: 'small', show: '.add-hyp', click: 'show', 'change'
          @div class: 'add-hyp', =>
            @subview 'hypernymPicker', new ReasonPicker(hint: 'it\'s a type of...', thing: 'Hypernym', type: value?.type)
          @div class: 'has_aliases', =>
            @p =>
              @text "Other words for this are: "
              @span class: 'aliases'
              @a class: 'small', show: '.no_aliases', click: 'show', 'add'
          @div class: 'no_aliases', =>
            @subview 'synonymPicker', new ReasonPicker(hint: 'Add a synonym', thing: 'Alias', type: value?.type)
          @ul click: 'viewReason', class: "requirements"
          @div class: 'add_requirements'

  onChoseAlias: (v) ->
    @value.mergeInto(v)
    @observe(@value = v, 'onReasonChanged')
    
  onAddedAlias: (text) -> @value.addAlias(text)
  onChoseHypernym: (v) -> @value.setHypernym(v)
  onChoseRequirement: (v) ->   @value.addRequirement(v)

  onReasonChanged: (v) ->
    v ||= {}
    @hypernym = Reason.fromId(v.kind_of) if v.kind_of
    @aliases = Object.keys(v.aliases || {})
    @configure()
    
    value = @value
    @find('.requirements').empty()
    for k, _v of v.requires || {}
      r = Reason.fromId(k)
      @find(".requirements").append $$ ->
        @li reason: r.id, =>
          @text "You need "
          @raw r.lozenge()
          @text " for "
          @b value.name
  
  viewReason: (ev) =>
    id = $(ev.target).attr('reason') || $(ev.target).parents('[reason]').attr('reason')
    @pushPage new ReasonEditor Reason.fromId(id) if id

  set_type: (ev) =>
    type = $(ev.target).attr('set') || $(ev.target).parents('[set]').attr('set')
    return unless type
    v = Reason.fromId("#{type}: #{@name}")
    @observe(@value = v, 'onReasonChanged')
    @configure()
 
  back: =>
    @value.store() if @value
    @popPage()
    @cb(@value) if @cb and @value

  
  # utils, maybe include in all views?
  
  show: (ev) =>
    @find($(ev.target).attr('show')).show()

  full_or_empty: (suffix, v) =>
    if v
      @find(".has_#{suffix}").show()
      @find(".no_#{suffix}").hide()
    else
      @find(".has_#{suffix}").hide()
      @find(".no_#{suffix}").show()
  
  