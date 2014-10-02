class window.ReasonEditor extends Page
  initialize: (v, @cb, @name) ->
    @observe(@value = v, 'onValueChanged')
    @observe current_user, 'observations', v if v
    @configure()
  
  onChoseAlias: (v) ->
    @value.mergeInto(v)
    @observe(@value = v, 'onValueChanged')
    @observe current_user, 'observations', v
   
  configure: =>
    v = @value
    @hypernymPicker.type = v.type
    @synonymPicker.type  = v.type
    @find('.requiredAssetPicker').toggle(v.hasRequiredAssets || false)
    @find('.forExperiencesPicker').toggle(v.hasKeyExperiences || false)
    @find('.ancestry').html(
      if v.isRoot()
        "#{v.lozenge()} is a good thing"
      else if @hypernym
        @find('.add-hyp').hide()
        "#{v.lozenge()} is a kind of #{@hypernym.lozenge()}"
      else 
        v.lozenge()
    )
  
  @content: (value, cb, name) ->
    @div class: 'reason_editor chilllozenges', =>
      @header class: 'bar bar-nav', =>
        @a class: 'icon icon-left-nav pull-left', click: 'back'
      @div class: 'content', =>
        @div class: 'content-padded', =>
          @p click: 'viewReason', =>
            @span class: 'ancestry'
            @a class: 'small gray icon icon-edit', show: '.add-hyp', click: 'show', ''
          @div class: 'add-hyp', =>
            @subview 'hypernymPicker', new ReasonPicker(hint: 'it\'s a type of...', thing: 'Hypernym', type: value?.type)
          
          @section class: 'aliasSection', =>
            @h4 'Also known as'
            @div class: 'aliases'
            @subview 'synonymPicker', new ReasonPicker(hint: 'Add a synonym', thing: 'Alias', type: value?.type)

          @section class: 'wisdom', =>
            @subview 'resourcePicker', new ReasonPicker hint: 'Add something...', style: 'margin: 5px; z-index: 10000; position: relative;', type: 'accomplishment'
            for x in ['whatleadsto', 'whatsatisfies']
              @h3 class: "#{x} header", =>
                @text x
                # @raw ' '
                # @raw value.lozenge()
              @ul click: 'listClicked', list: x, class: "table-view list #{x} expando"
          
          @section class: 'forExperiencesPicker', =>
            @h4 'Key aspects of the experience'
            @div click: 'viewReason', class: 'keyExperiences'
            @subview 'experiencePicker', new ReasonPicker(hint: "Add a feeling that defines this", thing: "ForExperience", type: 'experience')
          
          @section class: 'requiredAssetPicker', =>
            @h4 'Required assets'
            @div click: 'viewReason', class: 'requiredAssets'
            @subview 'assetPicker', new ReasonPicker(hint: "Add an asset its impossible without", thing: "RequiredAsset", type: 'asset')

  
 
  onAddedAlias: (text) -> @value.addAlias(text)
  onChoseHypernym: (v) -> @value.kindOf(v)
  onChoseForExperience: (v) -> @value.hasKeyExperience(v)
  onChoseRequiredAsset: (v) -> @value.requiresAsset(v)

  observationsChanged: (ary) ->
    @find(".list").empty()
    @find("h3.header").hide()

    for e in ary
      [ value1, rel, value2, num ] = e
      @find("h3.header.#{rel}").show()
      v = Value.fromId(value2)
      $v = $( v.asListEntry link: (if rel == 'Experiment' then 'refile') )
      @find(".#{rel}.list").append $v

  onChoseValue: (r) =>
    new Experiment(r, @value).claimedBy(current_user_id)

  listClicked: (ev) =>
    return if $(ev.target).parents('.bubble').length
    list = $(ev.target).pattr('list')
    subvalue = $(ev.target).pattr('subvalue')
    if list and subvalue
      new OutcomeChooser(Value.fromId(subvalue), @value, this)

  onValueChanged: (v) ->
    v ||= {}
    @hypernym = Value.fromId(Object.keys(v.kindOf)[0]) if v.kindOf
    @configure()
    
    @find('.aliases').html Object.keys(v.aliases || {}).join(', ')
    
    requiredAssetIds = Object.keys(v.requiredAssets || {})
    requiredAssetHTML = requiredAssetIds.map (x) ->
      Value.fromId(x).lozenge()
    .join ', '
    @find('.requiredAssets').html requiredAssetHTML
    
    keyExperienceIds = Object.keys(v.keyExperiences || {})
    keyExperienceHTML = keyExperienceIds.map (x) ->
      Value.fromId(x).lozenge()
    .join ', '
    @find('.keyExperiences').html keyExperienceHTML
    
  viewReason: (ev) =>
    id = $(ev.target).attr('reason') || $(ev.target).parents('[reason]').attr('reason')
    @pushPage new ReasonEditor Value.fromId(id) if id

  back: =>
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
  