class window.Review extends Popover
  @for_url: (url, cb) ->
    fb('resources/%', Links.asFirebasePath(url)).on 'value', (snap) =>
      v = snap.val()
      return cb(Review.for_obj(v)) if v
      Links.info url, (canonical_url, shortname, longname, img) ->
        obj =
          url: canonical_url
          name: shortname
          image: img
          type: Links.resourceType(canonical_url)
        fb('resources').child(Links.asFirebasePath(canonical_url)).set obj
        cb(Review.for_obj(obj))
  
  @open_url: (attach_element, url) ->
    Review.for_url url, (r) -> Popover.show(attach_element, r)

  @for_obj: (obj) ->
    obj.db =
      review: fb('user/%/reviews/%', window.current_user_id, Links.asFirebasePath(obj.url))
      engagement: fb('engagements/%/%', window.current_user_id, Links.asFirebasePath(obj.url))
      outcomes: fb('outcomes/%/%', window.current_user_id, Links.asFirebasePath(obj.url))
      desires: fb('desires/%', window.current_user_id)
      resource: fb('resources/%', Links.asFirebasePath(obj.url))
    new Pager(new Review(obj))

  @open: (attach_element, obj) ->
    Popover.show(attach_element, Review.for_obj(obj))

  @content: (ctx) ->
    {name, image, engagement, db} = ctx
    @div class: 'vreview', =>
      @ul class: 'table-view', =>
        @subview 'search', new Fireahead "What is #{name} about for you?", fb('tags'),
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
      if engagement
        @p class: 'reminder', "#{engagement.pasttense} #{engagement.ago} ago"
      else
        @p class: 'reminder', "This week, you've spent 4 hours"

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
