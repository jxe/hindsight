class window.ReasonEditor extends Page

  initialize: (@value, @cb, @name) ->
    @bind observationsChanged: Observations.live(current_user_id, @value)
    @synonymPicker.type  = @value.type
      
  onChoseAlias: (v) ->
    return alert 'uhoh'
    @value.mergeInto(v)
    # TODO, switch up bindings/observations
  
  onChoseWhy: (v) ->
    alert 'yaywhy'

  onChoseHow: (v) ->
    alert 'yayhow'

  listClicked: (ev) ->
    alert 'clicked'

  onAddedAlias: (text) -> @value.addAlias(text)

  viewReason: (ev) =>
    id = $(ev.target).attr('reason') || $(ev.target).parents('[reason]').attr('reason')
    @pushPage new ReasonEditor Good.fromId(id) if id

  observationsChanged: (o) ->
    @find('.aliases').html o.aliases.join(', ')

    whylist = @find('.whylist').empty()
    for x in o.whyObservations()
      whylist.append Good.fromId(x).asListEntry()

    howlist = @find('.howlist').empty()
    for x in o.howObservations()
      howlist.append Good.fromId(x).asListEntry()

  back: =>
    @popPage()
    @cb(@value) if @cb and @value

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

          # margin: 5px; z-index: 10000; position: relative
          
          @section class: 'why', =>
            @subview 'resourcePicker', new ReasonPicker hint: 'Add something...', thing: 'Why'
            @h3 class: "why header", "Why"
            @ul click: 'listClicked', list: x, class: "table-view list whylist expando"
          
          @section class: 'how', =>
            @subview 'resourcePicker', new ReasonPicker hint: 'Add something...', thing: 'How'
            @h3 class: "how header", "How"
            @ul click: 'listClicked', list: x, class: "table-view list howlist expando"


############################################################


class WhyMenu extends MenuModal
  initialize: (@value, @becauseValue, @cb) ->
    @prompt.html "Why do people turn to "+
        "#{@value.lozenge()} for #{@becauseValue.lozenge()}?"

  @options: [
    ['whatdrives', 'because of a groundless hope', 'close'],
    ['satisfies', 'because it works immediately', 'check'],
    ['leadsto', 'because it usually leads to that', 'more'],
    ['whatrequires', 'because it\'s necessary', 'more']
  ]


class HowMenu extends MenuModal
  initialize: (@value, @usingValue, @cb) ->
    @prompt.html "How does it go, getting "+
        "#{@value.lozenge()} using #{@usingValue.lozenge()}?"

  @options: [
    ['whatleadsto', 'it works out eventually', 'check'],
    ['whatisa', 'if you do one, you\'ve done the other', 'more'],
    ['defines', 'one is about the other', 'more'],
    ['whatsatisfies', 'works every time', 'check'],
  ]

