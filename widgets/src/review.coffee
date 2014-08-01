class window.Review extends Page
  inject: (el) ->
    $(el).html(new Pager(this))
  
  @fromResourceAndUser: (r, uid, is_child) ->
    p = r.firebase_path()
    new Review
      url: r.canonUrl,
      name: r.name(),
      is_child: is_child,
      db:
        review: fb('user/%/reviews/%', uid, p)
        engagement: fb('engagements/%/%', uid, p)
        outcomes: fb('outcomes/%/%', uid, p)
        desires: fb('desires/%', uid)
        resource: fb('resources/%', p)

  @content: (ctx) ->
    {name, engagement, db} = ctx
    @div class: 'vreview', =>
      @header class: 'bar bar-nav bar-extended', =>
        @a class: 'icon icon-left-nav pull-left', click: 'back' if ctx.is_child
        @subview 'search', new ReasonInput "Why #{name}?", (opt, el) ->
          obj = {}
          obj[ opt.name ] = { intended: true }
          db.outcomes.update(obj)
          db.engagement.update type: 'used'
          db.resource.child('tags').child(opt.name).child('added').set(true)
          el.parentView.editOutcome(opt.name)
        @p class: 'reminder', =>
          if engagement
             "#{engagement.pasttense} #{engagement.ago} ago"
          else
            @b "4 hours"
            @text " this week"
      @ul class: "table-view content", =>
        @div class: 'outcomes', outlet: 'outcomes', click: 'outcomeClicked'

  drawOutcomes: (myTags, commonTags, db) ->
    @outcomes.html $$ ->
      return unless myTags
      for tag in Review.sort_tags(myTags)
        data = myTags[tag]
        data.id = tag
        if data != false
          [ type, tagname ] = tag.split(': ')
          @li class: 'table-view-cell signalrow', tag: tag, =>
            @h3 class: data.going, =>
              @raw if data.going == 'well' then '<span class="icon icon-check"></span>' else ''
              @b Review.binary_text(type, data.going)
            @subview 'signal', Signal.withOutcome('..', data || { id: tag })
              
  @binary_text: (type, going) ->
    return '...' if !going
    well = (going == 'well')
    switch type
      when 'activity', 'asset', 'image', 'feeling', 'state', 'outcome'
        if well then 'It lead to' else 'Hasn\'t lead to'
      when 'faculty', 'virtue', 'ethic'
        if well then 'Was' else 'Was not'

  editOutcome: (tag) =>
    [ type, tagname ] = tag.split(': ')
    this.parents('.pager_viewport').view().push(new Outcome(@db, tag, tagname, @tags[ tag ], @name))
      
  outcomeClicked: (ev) =>
    tag = $(ev.target).attr('tag') || $(ev.target).parents('[tag]').attr('tag')
    @editOutcome(tag) if tag
          
  initialize: (ctx) ->
    { @item, @engagement, @db, @name } = ctx
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
      result.push(k) if tags[k]?.going == 'well'
    for k in keys
      result.push(k) if tags[k]?.going == 'poorly'
    for k in keys
      result.push(k) if !tags[k]?.going
    result
  