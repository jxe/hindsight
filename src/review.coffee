class window.Review extends Modal
  @content: (ctx) ->
    {name, image, engagement, db} = ctx
    @div class: 'vreview modal', =>
      @header class: 'bar bar-nav', =>
        @h1 class: 'title',  "Values Review"
        @a click: 'close', class: 'icon icon-close pull-right'
      @div class: 'content', =>
        @div class: 'content-padded', =>
          @div class:'item row', =>
            @img src: image
            @div =>
              @b name
              @p class: 'reminder', "#{engagement.pasttense} #{engagement.ago} ago" if engagement
          @div =>
            @span class: 'rationale', outlet: 'rationale', =>
        @div class: 'nosebox', =>
          @div class: 'nose'
        @ol class: 'table-view with-nose', =>
          @subview 'search', new Fireahead "Search / Add", fb('tags'),
            (clicked) ->
              if clicked.name
                obj = {}
                obj[ clicked.name ] = { intended: true }
                db.review.update(obj)
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
          for tag, data of myTags
            if data
              [ type, tagname ] = tag.split(': ')
              @b class: "#{type} #{data.now}", =>
                @img src: "img/#{type}.png"
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
    @sub @db.review, 'value', (snap) =>
      @tags = snap.val() || {}
      @drawRationale @tags
      @drawFollowups @tags, @common_tags, @db
    @sub @db.resource.child('tags'), 'value', (snap) =>
      @common_tags = snap.val() || {}
      console.log 'common_tags', @common_tags
      @drawFollowups @tags, @common_tags, @db
