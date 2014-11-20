class window.ObservationsEditor extends Page
  inject: (el) ->
    $(el).html(new Pager(this))

  initialize: (ctx) ->
    { @item, @engagement, @name, @resource } = ctx
    @engagement ||= @resource.asEngagement()
    @commonMotivations = []
    @bind observationsChanged: Observations.live(current_user_id, @engagement)
    fb('commonWisdom/%/whatdrives', @engagement.id).once 'value', (snap) =>
      v = snap.val()
      if v
        @commonMotivations = Object.keys(v)
      @redrawHints()

  redrawHints: =>
    return unless @currentObservations
    keys = (x for x in @commonMotivations when !@currentObservations.relatives[x])
    return unless keys and keys.length

    @hints.html $$ ->
      @div =>
        @p "Others said:"
        for id in keys
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
        @ul class: "table-view brightLozenges", =>
          @div class: 'outcomes', outlet: 'outcomes', click: 'outcomeClicked'
        @div class: 'hints expando', outlet: 'hints', click: 'hintClicked', ""
        @div class: 'promptBox', outlet: 'promptBox', style: "display:none"

  prompt: (text, cb) =>
    @promptBox.show().html(text).click(cb)

  thanks: =>
    @promptBox.html("Thanks")
    setTimeout((=> @promptBox.hide()), 1000)

  onChoseValue: (r) =>
    new ActivityClaimModal(@engagement, r, this)

  editOutcome: (tag) =>
    new ActivityClaimModal(@engagement, Good.fromId(tag), this)

  hintClicked: (ev) =>
    id = $(ev.target).pattr('reason')
    new ActivityClaimModal(@engagement, Good.fromId(id), this) if id

  yourGoals: =>
    @pushPage new PersonExperiencesInspector()

  outcomeClicked: (ev) =>
    tag = $(ev.target).pattr 'reason'
    if $(ev.target).hasClass('icon-close')
      # return unless confirm('Sure?')
      @currentObservations.remove(tag)
    else
      @editOutcome(tag) if tag

  observationsChanged: (o) ->
    @currentObservations = o
    arr = o.directObservations()
    @redrawHints()
    @hints.toggle( arr.length < 4 )
    
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


