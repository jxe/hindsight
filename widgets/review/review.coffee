class window.Review extends Modal
  @open_url: (url) ->
    fb('resources/%', Links.asFirebasePath(url)).on 'value', (snap) =>
      @open snap.val()

  @open: (obj) ->
    obj.db =
      review: fb('user/%/reviews/%', window.current_user_id, Links.asFirebasePath(obj.url))
      engagement: fb('engagements/%/%', window.current_user_id, Links.asFirebasePath(obj.url))
      outcomes: fb('outcomes/%/%', window.current_user_id, Links.asFirebasePath(obj.url))
      desires: fb('desires/%', window.current_user_id)
      resource: fb('resources/%', Links.asFirebasePath(obj.url))
    @show obj

  @content: (ctx) ->
    {name, image, engagement, db} = ctx
    @div class: 'vreview modal', =>
      @div class: 'content', =>
        @div class: 'content-padded', =>
          @div class:'item row', =>
            @img src: image
            @div =>
              @a click: 'close', class: 'icon icon-close pull-right'
              @h3 name
              @p class: 'reminder', "#{engagement.pasttense} #{engagement.ago} ago" if engagement
              @div class: 'rationale', outlet: 'rationale'
        @div class: 'popup', =>
          @div class: 'nose'
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
                name: "ethic: #{typed}"
                new: true
              ,
                name: "outcome: #{typed}"
                new: true
              ]
          @div class: 'outcomes', outlet: 'outcomes'

  drawRationale: (myTags) =>
    @rationale.html $$ ->
      if !myTags
        @span class: 'prompt', "What was #{engagement?.gerund || "engaging with"} this about?"
      else
        @span class: 'tagfield', =>
          @span class: 'label', "For you, it's about"
          for tag, data of myTags
            if data
              [ type, tagname ] = tag.split(': ')
              going_well_percent = if data.going == 'well' then 1.0 else 0.0
              r1w = r2x = going_well_percent * 14
              r2w = 14 - r1w
              svg = "<svg><rect fill='rgb(121, 211, 121)' x='0' y='0' width='#{r1w}' height='6'/><rect fill='rgb(196, 108, 108)' x='#{r2x}' y='0' width='#{r2w}' height='6'/></svg>"

              @b class: "#{type} #{data.now}", =>
                @raw svg
                # @img src: "img/#{type}.png"
                @text tagname
              @text ' '

  drawFollowups: (myTags, commonTags, db) ->
    for tag, data of commonTags
      myTags[tag] = 0 if myTags[tag] == undefined

    @outcomes.html $$ ->
      if myTags
        @div =>
          for tag in Object.keys(myTags).sort()
            data = myTags[tag]
            if data != false
              [ type, tagname ] = tag.split(': ')
              switch type
                when 'activity'
                  @div =>
                    @subview(tag, new ActivityResults(db, tag, tagname, data))

                when 'outcome'
                  @div =>
                    @subview(tag, new OutcomeResults(db, tag, tagname, data))

                when 'ethic'
                  @div =>
                    @subview(tag, new EthicResults(db, tag, tagname, data))


  initialize: (ctx) ->
    { @item, @engagement, @db } = ctx
    @tags = {}
    @common_tags = {}
    @sub @db.outcomes, 'value', (snap) =>
      @tags = snap.val() || {}
      @drawRationale @tags
      @drawFollowups @tags, @common_tags, @db
    @sub @db.resource.child('tags'), 'value', (snap) =>
      @common_tags = snap.val() || {}
      console.log 'common_tags', @common_tags
      @drawFollowups @tags, @common_tags, @db
