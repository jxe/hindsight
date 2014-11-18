class window.ReasonEditor extends Page
  initialize: (@value, @cb, @name) ->
    @bind observationsChanged: Observations.live(current_user_id, @value)
    @synonymPicker.type  = @value.type
  back: =>
    @popPage()
    @cb(@value) if @cb and @value
  
  onChoseAlias: (v) ->
    return alert 'uhoh'
    @value.mergeInto(v)
    # TODO, switch up bindings/observations

  viewReason: (ev) =>
    id = $(ev.target).pattr('reason')
    @pushPage new ReasonEditor Good.fromId(id) if id
  
  onChoseWhy: (v) ->
    @establishRelation(@value, v)
  onChoseHow: (v) ->
    @establishRelation(v, @value)
  whyClicked: (ev) =>
    v = Good.fromId($(ev.target).pattr('subvalue'))
    if $(ev.target).hasClass('icon-close')
      return unless confirm('Sure?')
      @currentObservations.remove(v.id)
    @establishRelation(@value, v)
  howClicked: (ev) =>
    v = Good.fromId($(ev.target).pattr('subvalue'))
    if $(ev.target).hasClass('icon-close')
      return unless confirm('Sure?')
      @currentObservations.remove(v.id)
    @establishRelation(v, @value)

  establishRelation: (value, parentValue) ->
    couldBeIncluded = parentValue.couldInclude(value)
    couldLeadTo     = value.couldLeadTo(parentValue)
    if couldBeIncluded and couldLeadTo
      return new GoodObservationMenu(value, parentValue).openIn(this)
    if couldBeIncluded
      return current_user.observes value, 'implements', parentValue, 1.0
    if couldLeadTo
      return current_user.observes value, 'delivers', parentValue, 1.0

  onChoseParent: (v) ->
    current_user.observes @value, 'implements', v

  onAddedAlias: (text) -> @value.addAlias(text)

  observationsChanged: (o) ->
    @currentObservations = o
    @find('.aliases').html o.aliases.join(', ')
    whylist = @find('.whylist').empty()
    for x in o.whyObservations()
      whylist.append Good.fromId(x).asListEntry(prefix: o.whyPrefix(x), closable: true)
    howlist = @find('.howlist').empty()
    for x in o.howObservations()
      howlist.append Good.fromId(x).asListEntry(suffix: o.howSuffix(x), closable: true)
    @find('.parents').html $$ ->
      for x, _ of o.connections.implements
        @raw Good.fromId(x).asListEntry()

  @content: (value, cb, name) ->
    @div class: 'reason_editor', =>
      @header class: 'bar bar-nav', =>
        @a class: 'icon icon-left-nav pull-left', click: 'back'
      @div class: 'content', =>
        @div class: 'content-padded', =>
          @p click: 'viewReason', =>
            @raw value.lozenge()
          @section class: 'why', =>
            @h4 class: "why header distinctive", "Why do people value this?"
            @subview 'resourcePicker', new ReasonPicker hint: 'Add a reason...', thing: 'Why'
            @ul click: 'whyClicked', list: 'why', class: "table-view list whylist expando"
          @section class: 'how', =>
            @h4 class: "how header distinctive", "How do people pursue this?"
            @subview 'resourcePicker', new ReasonPicker hint: 'Add a method...', thing: 'How'
            @ul click: 'howClicked', list: 'how', class: "table-view list howlist expando"
          @section class: 'aliasSection', =>
            @h4 class: 'distinctive', 'What else would you call it?'
            @div class: 'aliases'
            @subview 'synonymPicker', new ReasonPicker(hint: 'Add an alias', thing: 'Alias', type: value?.type)
