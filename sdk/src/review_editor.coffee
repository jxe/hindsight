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
          @div class: 'expando', click: 'yourGoals', =>
            @text "Favorites"
        @subview 'search', new ReasonPicker(hint: "Why #{name}?")
      @ul class: "table-view content", =>
        @div class: 'outcomes', outlet: 'outcomes', click: 'outcomeClicked'

  onChoseReason: (r) =>
    @pushPage new ListsEditor r, @resource
    
  yourGoals: =>
    @pushPage new PersonExperiencesInspector()

  editOutcome: (tag) =>
    @pushPage(new ListsEditor(Value.fromId(tag), @resource))
    
  outcomeClicked: (ev) =>
    tag = $(ev.target).pattr 'reason'
    if $(ev.target).hasClass('icon-close')
      alert 'todo'
#      return unless confirm('Sure?')
#      @resource.outcomesForUser(current_user_id, tag, null)
    else
      @editOutcome(tag) if tag
  
  initialize: (ctx) ->
    { @item, @engagement, @name, @resource } = ctx
    @observe Someone.usingThis(), 'onListsFor', value: @resource.asEngagement()
    
  onListsFor: (lists) ->
    @outcomes.html $$ ->
      for list, subvalues of lists
        for subvalue in subvalues
          v = Value.fromId(subvalue)
          positive = (list != 'distractionFor')
          @li class: 'table-view-cell signalrow', reason: subvalue, =>
            @a class: 'icon icon-close btn btn-link gray'
            @h3 class: ( if positive then 'well' else 'poorly' ), =>
              @raw  '<span class="icon icon-check"></span>' if positive
              @b list
            @raw v.lozenge(list)

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