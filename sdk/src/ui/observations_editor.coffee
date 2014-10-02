class window.ObservationsEditor extends Page
  inject: (el) ->
    $(el).html(new Pager(this))

  initialize: (ctx) ->
    { @item, @engagement, @name, @resource } = ctx
    @engagement ||= @resource.asEngagement()
    @observe current_user, 'observations', @engagement
    fb('common/evaluatingfor/%', @engagement.id).once 'value', (snap) =>
      @showHints Object.keys snap.val()

  showHints: (ids) =>
    @hints.html $$ ->
      @div =>
        @p "Others said:"
        for id in ids
          @a reason: id, Good.fromId(id).name
          @raw " &nbsp; "

  @fromResourceAndUser: (r, uid, is_child) ->
    p = r.firebase_path()
    new ObservationsEditor
      url: r.canonUrl,
      resource: r,
      name: r.name(),
      is_child: is_child

  @content: (ctx) ->
    {name, engagement, resource} = ctx
    @div class: 'vreview', =>
      @header class: 'bar bar-nav bar-extended', =>
        @a class: 'icon icon-left-nav pull-left', click: 'back' if ctx.is_child
        @div class: 'row inset_text', =>
          @div class: 'expando', =>
            if engagement
               "#{engagement.pasttense} #{engagement.ago} ago"
            else
              @b "4 hours"
              @text " this week"
          # @div class: 'expando', click: 'yourGoals', =>
          #   @text "Favorites"
        @subview 'search', new ReasonPicker(hint: "Why #{name}?")
      @div class: 'content column', =>
        @ul class: "table-view", =>
          @div class: 'outcomes', outlet: 'outcomes', click: 'outcomeClicked'
        @div class: 'hints expando', outlet: 'hints', click: 'hintClicked', "Hints here"
        @div class: 'promptBox', outlet: 'promptBox', style: "display:none"

  prompt: (text, cb) =>
    @promptBox.show().html(text).click(cb)

  thanks: =>
    @promptBox.html("Thanks")
    setTimeout((=> @promptBox.hide()), 1000)



  onChoseValue: (r) =>
    new ObservationEditor(@engagement, r, this)
    fb('common/evaluatingfor/%/%/%', @engagement.id, r.id, current_user_id).set true

  editOutcome: (tag) =>
    new ObservationEditor(@engagement, Good.fromId(tag), this)

  hintClicked: (ev) =>
    id = $(ev.target).attr('reason') || $(ev.target).parents('[reason]').attr('reason')
    new ObservationEditor(@engagement, Good.fromId(id), this)


  yourGoals: =>
    @pushPage new PersonExperiencesInspector()


  didChooseOutcome: ->

  outcomeClicked: (ev) =>
    tag = $(ev.target).pattr 'reason'
    relation = $(ev.target).pattr 'relation'
    if $(ev.target).hasClass('icon-close')
      return unless confirm('Sure?')
      current_user.unobserves @engagement, relation, Good.fromId(tag)
    else
      @editOutcome(tag) if tag

  observationsChanged: (ary) ->
    if ary.length > 1 then @hints.hide() else @hints.show() 
    @outcomes.html $$ ->
      for e in ary
        v = Good.fromId(e[2])
        positive = (e[3] > 0.5)
        @li class: 'table-view-cell signalrow', reason: e[2], =>
          @a relation: e[1], class: 'icon icon-close btn btn-link gray'
          @h3 class: ( if positive then 'well' else 'poorly' ), =>
            @raw  '<span class="icon icon-check"></span>' if positive
            @b Observations.infixPhrase(e[1], e[3])
          @raw v.lozenge(e[1], e[3])

#  @sort_tags: (tags) ->
#    keys = Object.keys(tags).sort()
#    result = []
#    # add goingWell, then goingPoorly, then other
#    for k in keys
#      result.push(k) if tags[k]?.assessment == 'delivered'
#    for k in keys
#      result.push(k) if tags[k]?.assessment != 'delivered'
##    for k in keys
##      result.push(k) if !tags[k]?.going
#    result
#


class window.MoreImportantGoodCollector extends Modal
  initialize: (@justifier, @options) ->
    @justifier.prompt "What is more important to you now than #{@options.value.lozenge()}?", =>
      @openIn(@justifier)
  @content: (justifier, options) ->
    @div class: 'hovermodal chilllozenges MoreImportantGoodCollector', =>
      @div class: 'content-padded', =>
        @h4 =>
          @raw "Add a goal that trumps #{options.value.lozenge()}"
      @subview 'search', new ReasonPicker(hint: "add a goal...")
  onChoseValue: (v) =>
    current_user.observes v, "trumps", @options.value, 1.0
    @close()
    @justifier.thanks()

class window.BetterActivityCollector extends Modal
  initialize: (@justifier, @options) ->
    @justifier.prompt "What does help, with #{@options.value.lozenge()}?", =>
      @openIn(@justifier)
  @content: (justifier, options) ->
    @div class: 'hovermodal chilllozenges BetterActivityCollector', =>
      @div class: 'content-padded', =>
        @h4 =>
          @raw "Add a better activity for #{options.value.lozenge()}"
      @subview 'search', new ReasonPicker(hint: "add an activity...")
      @div outlet: 'pickedValue'
      @button click: 'leadTo', class: 'btn btn-block', "lead to"
      @button click: 'satisfied', class: 'btn btn-block', "immediately satisfied"
  onChoseValue: (v) =>
    @chosenValue = v
    @pickedValue.html v.lozenge()
  leadTo: (v) =>
    current_user.observes @chosenValue, "leadsto", @options.value, 1.0
    @close()
    @justifier.thanks()
  satisfied: (v) =>
    current_user.observes @chosenValue, "satisfies", @options.value, 1.0
    @close()
    @justifier.thanks()

class window.KeyAssetCollector extends Modal
  initialize: (@justifier, @options) ->
    @justifier.prompt "What did #{@options.provider.lozenge()} give you that's good for #{@options.value.lozenge()}?", =>
      @openIn(@justifier)
  @content: (justifier, options) ->
    @div class: 'hovermodal chilllozenges KeyAssetCollector', =>
      @div class: 'content-padded', =>
        @h4 =>
          @raw "What did #{options.provider.lozenge()} give you that's good for #{options.value.lozenge()}"
      @subview 'search', new ReasonPicker(hint: "add a goal...")
  onChoseValue: (v) =>
    current_user.observes @options.provider, 'satisfies', v, 1.0
    current_user.claims @options.value, 'requires', v
    @close()
    @justifier.thanks()
