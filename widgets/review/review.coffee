class window.Review extends Popover
  @open_url: (attach_element, url) ->
    fb('resources/%', Links.asFirebasePath(url)).on 'value', (snap) =>
      @open attach_element, snap.val()

  @open: (attach_element, obj) ->
    obj.db =
      review: fb('user/%/reviews/%', window.current_user_id, Links.asFirebasePath(obj.url))
      engagement: fb('engagements/%/%', window.current_user_id, Links.asFirebasePath(obj.url))
      outcomes: fb('outcomes/%/%', window.current_user_id, Links.asFirebasePath(obj.url))
      desires: fb('desires/%', window.current_user_id)
      resource: fb('resources/%', Links.asFirebasePath(obj.url))
    @show attach_element, obj

  @content: (ctx) ->
    {name, image, engagement, db} = ctx
    @div class: 'vreview popover', =>
      @ul class: 'table-view', =>
        @p class: 'reminder', "#{engagement.pasttense} #{engagement.ago} ago" if engagement
        @subview 'search', new Fireahead "Add", fb('tags'),
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
              name: "virtue: #{typed}"
              new: true
            ,
              name: "state: #{typed}"
              new: true
            ]
      @div class: 'outcomes', outlet: 'outcomes'

  drawFollowups: (myTags, commonTags, db) ->
    for tag, data of commonTags
      myTags[tag] = 0 if myTags[tag] == undefined

    @outcomes.html $$ ->
      if myTags
        @div =>
          for tag in Object.keys(myTags).sort()
            data = myTags[tag]
            data.id = tag
            if data != false
              [ type, tagname ] = tag.split(': ')
              switch type
                when 'activity'
                  @div =>
                    @subview(tag, new ActivityResults(db, tag, tagname, data))

                when 'outcome', 'state'
                  @div =>
                    @subview(tag, new OutcomeResults(db, tag, tagname, data))

                when 'ethic', 'virtue'
                  @div =>
                    @subview(tag, new EthicResults(db, tag, tagname, data))


  initialize: (ctx) ->
    { @item, @engagement, @db } = ctx
    @tags = {}
    @common_tags = {}
    @sub @db.outcomes, 'value', (snap) =>
      @tags = snap.val() || {}
      # @drawRationale @tags
      @drawFollowups @tags, @common_tags, @db
    @sub @db.resource.child('tags'), 'value', (snap) =>
      @common_tags = snap.val() || {}
      console.log 'common_tags', @common_tags
      @drawFollowups @tags, @common_tags, @db
