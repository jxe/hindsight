class window.ResourceExperienceEditor extends Page
  inject: (el) ->
    $(el).html(new Pager(this))

  @fromResourceAndUser: (r, uid, is_child) ->
    p = r.firebase_path()
    new ResourceExperienceEditor
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
        @ul class: "table-view expando", =>
          @div class: 'outcomes', outlet: 'outcomes', click: 'outcomeClicked'
        @div class: 'promptBox', outlet: 'promptBox', style: "display:none"

  prompt: (text, cb) =>
    @promptBox.show().html(text).click(cb)

  thanks: =>
    @promptBox.html("Thanks")
    setTimeout((=> @promptBox.hide()), 1000)

  onChoseValue: (r) =>
    new OutcomeChooser(Engagement.fromResource(@resource), r, this)
    # @pushPage new ListsEditor r, @resource

  yourGoals: =>
    @pushPage new PersonExperiencesInspector()

  editOutcome: (tag) =>
    new OutcomeChooser(Engagement.fromResource(@resource), Value.fromId(tag), this)
    # @pushPage(new ListsEditor(Value.fromId(tag), @resource))

  didChooseOutcome: ->

  outcomeClicked: (ev) =>
    tag = $(ev.target).pattr 'reason'
    # if $(ev.target).hasClass('icon-close')
    #   return unless confirm('Sure?')
    #   Wisdom.destroy(current_user_id, Engagement.fromResource(@resource), Value.fromId(tag))
    # else
    @editOutcome(tag) if tag

  initialize: (ctx) ->
    { @item, @engagement, @name, @resource } = ctx
    @observe current_user, 'learnings', @resource.asEngagement()
    # @prompt "Please click me", => @thanks()

  learningsChanged: (ary) ->
    @outcomes.html $$ ->
      for e in ary
        v = Value.fromId(e[2])
        positive = (e[3] > 0.5)
        @li class: 'table-view-cell signalrow', reason: e[2], =>
          @a class: 'icon icon-close btn btn-link gray'
          @h3 class: ( if positive then 'well' else 'poorly' ), =>
            @raw  '<span class="icon icon-check"></span>' if positive
            @b Learnings.infixPhrase(e[1], e[3])
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


class window.MoreImportantValueCollector extends Modal
  initialize: (@justifier, @options) ->
    @justifier.prompt "What is more important to you now than #{@options.value.lozenge()}?", =>
      @openIn(@justifier)
  @content: (justifier, options) ->
    @div class: 'hovermodal chilllozenges MoreImportantValueCollector', =>
      @div class: 'content-padded', =>
        @h4 =>
          @raw "Add a goal that trumps #{options.value.lozenge()}"
      @subview 'search', new ReasonPicker(hint: "add a goal...")
  onChoseValue: (v) =>
    # do some stuff...
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
    # do some stuff...
    @close()
    @justifier.thanks()

class window.KeyAssetCollector extends Modal
  initialize: (@justifier, @options) ->
    @justifier.prompt "What is more important to you now than #{@options.value.lozenge()}?", =>
      @openIn(@justifier)
  @content: (justifier, options) ->
    @div class: 'hovermodal chilllozenges KeyAssetCollector', =>
      @div class: 'content-padded', =>
        @h4 =>
          @raw "Add a goal that trumps #{@options.value.lozenge()}"
      @subview 'search', new ReasonPicker(hint: "add a goal...")
  onChoseValue: (v) =>
    # do some stuff...
    @close()
    @justifier.thanks()
