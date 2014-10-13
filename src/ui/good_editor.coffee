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
  onAddedAlias: (text) -> @value.addAlias(text)

  viewReason: (ev) =>
    id = $(ev.target).pattr('reason')
    @pushPage new ReasonEditor Good.fromId(id) if id
  
  onChoseWhy: (v) ->
    new GoodObservationMenu(@value, v).openIn(this)
  onChoseHow: (v) ->
    new GoodObservationMenu(v, @value).openIn(this)
  whyClicked: (ev) =>
    onChoseWhy $(ev.target).pattr('[subvalue]')
  howClicked: (ev) =>
    onChoseHow $(ev.target).pattr('[subvalue]')

  observationsChanged: (o) ->
    @find('.aliases').html o.aliases.join(', ')
    whylist = @find('.whylist').empty()
    for x in o.whyObservations()
      whylist.append Good.fromId(x).asListEntry(prefix: o.whyPrefix(x))
    howlist = @find('.howlist').empty()
    for x in o.howObservations()
      howlist.append Good.fromId(x).asListEntry(suffix: o.howSuffix(x))

  @content: (value, cb, name) ->
    @div class: 'reason_editor chilllozenges', =>
      @header class: 'bar bar-nav', =>
        @a class: 'icon icon-left-nav pull-left', click: 'back'
      @div class: 'content', =>
        @div class: 'content-padded', =>
          @p click: 'viewReason', =>
            @raw value.lozenge()
          @section class: 'aliasSection', =>
            @h4 'Also known as'
            @div class: 'aliases'
            @subview 'synonymPicker', new ReasonPicker(hint: 'Add a synonym', thing: 'Alias', type: value?.type)
          @section class: 'why', =>
            @h3 class: "why header", "Why"
            @subview 'resourcePicker', new ReasonPicker hint: 'Add something...', thing: 'Why'
            @ul click: 'whyClicked', list: 'why', class: "table-view list whylist expando"
          @section class: 'how', =>
            @h3 class: "how header", "How"
            @subview 'resourcePicker', new ReasonPicker hint: 'Add something...', thing: 'How'
            @ul click: 'howClicked', list: 'how', class: "table-view list howlist expando"
