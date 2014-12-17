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
    @askHow(@value, helpsWith: v)
  onChoseHow: (v) ->
    @askHow(v, helpsWith: @value)
  whyClicked: (ev) =>
    v = Good.fromId($(ev.target).pattr('subvalue'))
    return @currentObservations.remove(v.id) if $(ev.target).hasClass('icon-close')
    # @askHow(@value, helpsWith: v)
    @pushPage new ReasonEditor v
  howClicked: (ev) =>
    v = Good.fromId($(ev.target).pattr('subvalue'))
    return @currentObservations.remove(v.id) if $(ev.target).hasClass('icon-close')
    # @askHow(v, helpsWith: @value)
    @pushPage new ReasonEditor v

  askHow: (@component, x) =>
    @helpsWith = x.helpsWith
    o = {}
    if component.couldBeHonoredAs(@helpsWith)
      label = component.honoredAsLabel(@helpsWith)
      if component.isActivity and @helpsWith.isActivity
        o.honoredas = "#{@component.lozenge()} #{label} #{@helpsWith.lozenge()}"
        o.whathonoredas = "#{@helpsWith.lozenge()} #{label} #{@component.lozenge()}"
      else
        o.honoredas = "#{@component.lozenge()} #{label} #{@helpsWith.lozenge()}"
    if component.couldDeliver(@helpsWith)
      o.delivers = "#{@component.lozenge()} leads to #{@helpsWith.lozenge()}"
    if @helpsWith.couldDrive(component)
      o.promises = "People <i>hope</i> #{@component.lozenge()} will lead to #{@helpsWith.lozenge()}, but it doesn't"
    @menu 'how', "Why do people turn to #{@component.lozenge()} for #{@helpsWith.lozenge()}?", o

  howClicked: (answer) =>
    switch answer
      when 'delivers'
        current_user.observes @component, 'delivers', @helpsWith, 1.0
      when 'promises'
        current_user.observes @component, 'promises', @helpsWith, 1.0
      when 'honoredas'
        current_user.observes @component, 'honoredas', @helpsWith, 1.0
      when 'whathonoredas'
        current_user.observes @helpsWith, 'honoredas', @component, 1.0

  onChoseParent: (v) ->
    current_user.observes @value, 'honoredas', v

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
      for x, _ of o.connections.honoredas
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
