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
    @find('.requiredAssetPicker').toggle(v.couldRequireCapacities)
    @find('.forExperiencesPicker').toggle(v.couldHaveKeyExperiences)
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
  
  
  @content: (value, cb, name) ->
    @div class: 'reason_editor', =>
      @header class: 'bar bar-nav', =>
        @a class: 'icon icon-left-nav pull-left', click: 'back'
      @div class: 'content', =>
        @div class: 'no_value content-padded', =>
          @h4 class: 'prompt', =>
            @raw "<b>#{name}</b> is something to..."
          for type in Reason.types
            @button class: 'btn btn-block', set: type, click: 'set_type', =>
              @raw Reason.desc(type)

        @div class: 'has_value content-padded', =>
          @p click: 'viewReason', =>
            @span class: 'ancestry'
            @a class: 'small gray icon icon-edit', show: '.add-hyp', click: 'show', ''
          @div class: 'add-hyp', =>
            @subview 'hypernymPicker', new ReasonPicker(hint: 'it\'s a type of...', thing: 'Hypernym', type: value?.type)
          @div class: 'has_aliases', =>
            @p =>
              @text "It's also called "
              @i class: 'aliases'
              @a class: 'small gray icon icon-plus', show: '.no_aliases', click: 'show', ''
          @div class: 'no_aliases', =>
            @subview 'synonymPicker', new ReasonPicker(hint: 'Add a synonym', thing: 'Alias', type: value?.type)
          @div outlet: "notes", click: 'viewReason', class: "notes"
          
          @div class: 'forExperiencesPicker', =>
            @subview 'experiencePicker', new ReasonPicker(hint: "Are certain experiences key for this?", thing: "ForExperience", type: 'experience')
          @div class: 'requiredAssetPicker', =>
            @subview 'assetPicker', new ReasonPicker(hint: "Is this impossible wihtout assets or abilities?", thing: "RequiredCapacity", type: 'capacity')
          
  

  onChoseAlias: (v) ->
    @value.mergeInto(v)
    @observe(@value = v, 'onReasonChanged')
    
  onAddedAlias: (text) -> @value.addAlias(text)
  onChoseHypernym: (v) -> @value.kindOf(v)
  onChoseForExperience: (v) -> @value.hasKeyExperience(v)
  onChoseRequiredCapacity: (v) -> @value.requiresCapacity(v)

  onReasonChanged: (v) ->
    v ||= {}
    @hypernym = Reason.fromId(Object.keys(v.kindOf)[0]) if v.kindOf
    @aliases = Object.keys(v.aliases || {})
    @configure()
    @notes.empty()
    for asset_id, _ of v.requiredCapacities || {}
      @notes.append $$ ->
        @p =>
          @text "This takes "
          @raw Reason.fromId(asset_id).lozenge()
    for experience_id, _ of v.keyExperiences || {}
      @notes.append $$ ->
        @p =>
          @text "A key experience is "
          @raw Reason.fromId(experience_id).lozenge()

  viewReason: (ev) =>
    id = $(ev.target).attr('reason') || $(ev.target).parents('[reason]').attr('reason')
    @pushPage new ReasonEditor Reason.fromId(id) if id

  set_type: (ev) =>
    type = $(ev.target).attr('set') || $(ev.target).parents('[set]').attr('set')
    return unless type
    @observe(@value = Reason.create(type, @name), 'onReasonChanged')
    @configure()
 
  back: =>
    @value.store() if @value
    @popPage()
    @cb(@value) if @cb and @value

  
  # utils, maybe include in all views?
  
  show: (ev) =>
    @find($(ev.target).attr('show')).toggle()

  full_or_empty: (suffix, v) =>
    if v
      @find(".has_#{suffix}").show()
      @find(".no_#{suffix}").hide()
    else
      @find(".has_#{suffix}").hide()
      @find(".no_#{suffix}").show()
  
  