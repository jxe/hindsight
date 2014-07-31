class window.Review extends View
  inject: (el) ->
    $(el).html(new Pager(this))
  
  @fromResourceAndUser: (r, uid) ->
    p = r.firebase_path()
    new Review
      url: r.canonUrl,
      name: r.name,
      db:
        review: fb('user/%/reviews/%', uid, p)
        engagement: fb('engagements/%/%', uid, p)
        outcomes: fb('outcomes/%/%', uid, p)
        desires: fb('desires/%', uid)
        resource: fb('resources/%', p)

  @content: (ctx) ->
    {name, engagement, db} = ctx
    @div class: 'vreview', =>
      @ul class: 'table-view', =>
        @subview 'search', new Fireahead "Why #{name}?", fb('tags'),
          (clicked) ->
            if clicked.name
              obj = {}
              obj[ clicked.name ] = { intended: true }
              db.outcomes.update(obj)
              db.engagement.update type: 'used'
              db.resource.child('tags').child(clicked.name).child('added').set(true)
              if clicked.new
                fb('tags').child(clicked.name).set name: clicked.name
          ,
          (typed) ->
            return [
              name: "activity: #{typed}"
              new: true
            ,
              name: "faculty: #{typed}"
              new: true
            ,
              name: "image: #{typed}"
              new: true
            ,
              name: "asset: #{typed}"
              new: true
            ,
              name: "feeling: #{typed}"
              new: true
            ]
        @div class: 'outcomes', outlet: 'outcomes', click: 'outcomeClicked'
      if engagement
        @p class: 'reminder', "#{engagement.pasttense} #{engagement.ago} ago"
      else
        @p class: 'reminder', =>
          @b "4 hours"
          @text " this week"

  drawFollowups: (myTags, commonTags, db) ->
    @outcomes.html $$ ->
      return unless myTags
      for tag in Object.keys(myTags).sort()
        data = myTags[tag]
        data.id = tag
        if data != false
          [ type, tagname ] = tag.split(': ')
          @li class: 'table-view-cell signalrow', tag: tag, =>
            @h3 class: data.going, =>
                @span Review.binary_text(type, data.going)
            @subview 'signal', Signal.withOutcome('..', data || { id: tag })
              
  @binary_text: (type, going) ->
    return '...' if !going
    well = (going == 'well')
    switch type
      when 'activity', 'asset', 'image', 'feeling', 'state', 'outcome'
        if well then 'Lead to' else 'Hasn\'t lead to'
      when 'faculty', 'virtue', 'ethic'
        if well then 'Was' else 'Was not'

    
  outcomeClicked: (ev) ->
    tag = $(ev.target).attr('tag') || $(ev.target).parents('[tag]').attr('tag')
    if tag
      [ type, tagname ] = tag.split(': ')
      this.parents('.pager_viewport').view().push(new Outcome(@db, tag, tagname, @tags[ tag ]))
  
          
  initialize: (ctx) ->
    { @item, @engagement, @db } = ctx
    @tags = {}
    @common_tags = {}
    @sub @db.outcomes, 'value', (snap) =>
      @tags = snap.val() || {}
      @drawFollowups @tags, @common_tags, @db
    @sub @db.resource.child('tags'), 'value', (snap) =>
      @common_tags = snap.val() || {}
      console.log 'common_tags', @common_tags
      @drawFollowups @tags, @common_tags, @db
