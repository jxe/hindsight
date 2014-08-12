class window.ResourceExperienceEditor extends Page
  inject: (el) ->
    $(el).html(new Pager(this))
  
  @fromResourceAndUser: (r, uid, is_child) ->
    p = r.firebase_path()
    new ResourceExperienceEditor
      url: r.canonUrl,
      resource: r,
      name: r.name(),
      is_child: is_child,
      db:
        engagement: fb('experience/%/resources/%', uid, p)
        outcomes: fb('experience/%/resources/%/for', uid, p)
        resource: fb('resources/%', p)

  @content: (ctx) ->
    {name, engagement, db, resource} = ctx
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
    @db.outcomes.child(r.id).update expected: true
#    @db.engagement.update type: 'used'
#    @db.resource.child('reasons').child(r.id).child('added').set(true)
    @pushPage(new ReasonExperiencesEditor(Reason.fromId(r.id), @resource))
    
  yourGoals: =>
    @pushPage new PersonExperiencesInspector()
  
  drawOutcomes: (myTags, commonTags, db) ->
    @outcomes.html $$ ->
      return unless myTags
      for tag in ResourceExperienceEditor.sort_tags(myTags)
        data = myTags[tag]
        data.id = tag
        if data != false
          v = Reason.fromId(tag)
          [ type, tagname ] = tag.split(': ')
          @li class: 'table-view-cell signalrow', tag: tag, =>
            @a class: 'icon icon-close btn btn-link gray'
            positive = (data.assessment == 'delivered' or data.assessment == 'helpedWith')
            @h3 class: ( if positive then 'well' else 'poorly' ), =>
              @raw  '<span class="icon icon-check"></span>' if positive
              @b v.labelFor(data.assessment)
            @raw v.lozenge(data.assessment)

  editOutcome: (tag) =>
    @pushPage(new ReasonExperiencesEditor(Reason.fromId(tag), @resource))
    
  outcomeClicked: (ev) =>
    tag = $(ev.target).attr('tag') || $(ev.target).parents('[tag]').attr('tag')
    if $(ev.target).hasClass('icon-close')
      return unless confirm('Sure?')
      @db.outcomes.child(tag).set(false)
    else
      @editOutcome(tag) if tag
  
  initialize: (ctx) ->
    { @item, @engagement, @db, @name, @resource } = ctx
    @tags = {}
    @common_tags = {}
    @sub @db.outcomes, 'value', (snap) =>
      @tags = snap.val() || {}
      @drawOutcomes @tags, @common_tags, @db
    @sub @db.resource.child('tags'), 'value', (snap) =>
      @common_tags = snap.val() || {}
      console.log 'common_tags', @common_tags
      @drawOutcomes @tags, @common_tags, @db

  @sort_tags: (tags) ->
    keys = Object.keys(tags).sort()
    result = []
    # add goingWell, then goingPoorly, then other
    for k in keys
      result.push(k) if tags[k]?.assessment == 'delivered'
    for k in keys
      result.push(k) if tags[k]?.assessment != 'delivered'
#    for k in keys
#      result.push(k) if !tags[k]?.going
    result
  