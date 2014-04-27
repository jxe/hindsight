class window.Review extends View
  @content: (item, engagement, fbref, common_tags) ->
    @div class: 'vreview', =>
      @header class: 'row bar bar-nav', =>
        @h1 class: 'title',  "Values Review"
      @div class: 'content', =>
        @div class: 'content-padded', =>
          @div class:'item row', =>
            @img src: item.img
            @div =>
              @b item.name
              @p class: 'reminder', "#{engagement.pasttense} #{engagement.ago} ago"
        @ol class: 'table-view', click: 'editRationale', =>
          @li class: 'table-view-cell', =>
            @span class: 'btn btn-link icon icon-plus circled gray'
            @span class: 'rationale', outlet: 'rationale', =>
              @span class: 'prompt', "What was #{engagement.gerund} this about?"
        @div class: 'outcomes', outlet: 'outcomes'

  editRationale: ->
    x = new RationaleEditor(@item, @engagement, @fbref, @common_tags)
    x.appendTo 'body'
    setTimeout((-> x.toggleClass 'active'), 0)

  initialize: (@item, @engagement, @fbref, @common_tags) ->
    @sub @fbref, 'value', (snap) =>
      tags = snap.val()

      @rationale.html $$ ->
        if !tags
          @span class: 'prompt', "What was #{engagement.gerund} this about?"
        else
          @span class: 'tagfield', click: 'showTagEditor', =>
            for tag, data of tags
              [ type, tagname ] = tag.split(': ')
              @b class: "#{type} #{data.now}", =>
                @img src: "img/#{type}.png"
                @text tagname
              @text ' '

      @outcomes.html $$ ->
        if tags
          @div class: 'content-padded', =>
            @h5 "How do you feel about it now?" # how has it gone?
          @ul class: 'table-view', =>
            for tag, data of tags
              [ type, tagname ] = tag.split(': ')

              switch type
                when 'activity'
                  @div =>
                    @subview(tag, new ActivityResults(fbref, tag, tagname, data))

                when 'outcome'
                  @div =>
                    @subview(tag, new OutcomeResults(fbref, tag, tagname, data))

                when 'ethic'
                  @div =>
                    @subview(tag, new EthicResults(fbref, tag, tagname, data))
