class window.ObservationsEditor extends Page
  inject: (el) ->
    $(el).html(new Pager(this))

  initialize: (ctx) ->
    { @item, @engagement, @name, @resource } = ctx
    @engagement ||= @resource.asEngagement()
    @bind observationsChanged: Observations.live(current_user_id, @engagement)
    fb('conclusions/whatdrives/%', @engagement.id).once 'value', (snap) =>
      v = snap.val()
      @showHints Object.keys(v) if v

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
    new EngagementObservationMenu(@engagement, r, this)

  editOutcome: (tag) =>
    new EngagementObservationMenu(@engagement, Good.fromId(tag), this)

  hintClicked: (ev) =>
    id = $(ev.target).attr('reason') || $(ev.target).parents('[reason]').attr('reason')
    new EngagementObservationMenu(@engagement, Good.fromId(id), this)

  yourGoals: =>
    @pushPage new PersonExperiencesInspector()

  outcomeClicked: (ev) =>
    tag = $(ev.target).pattr 'reason'
    if $(ev.target).hasClass('icon-close')
      return unless confirm('Sure?')
      @currentObservations.remove(tag)
    else
      @editOutcome(tag) if tag

  observationsChanged: (o) ->
    @currentObservations = o
    arr = o.directObservations()
    @hints.toggle( arr.length < 2 )
    
    @outcomes.html $$ ->
      for related_value_id in arr
        valence = o.valence(related_value_id)
        @li class: 'table-view-cell signalrow', reason: related_value_id, =>
          @a class: 'icon icon-close btn btn-link gray'
          @h3 class: valence, =>
            @raw  '<span class="icon icon-check"></span>' if valence == 'positive'
            @b o.infixPhrase(related_value_id)
          @raw Good.fromId(related_value_id).lozenge(valence)

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
  onChoseValue: (v) =>
    current_user.observes v, "delivers", @options.value, 1.0
    @close()
    @justifier.thanks()
