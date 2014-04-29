class window.RationaleEditor extends Modal
  @content: (item, engagement, fbref, common_tags) ->
    @div class: 'modal rationale_editor', =>
      @ul class: 'table-view', =>
        @li class: 'table-view-divider engagement', =>
          @text "What was "
          @b engagement?.gerund || "engaging with"
          @text " this about?"
          @span click: 'close', class: 'media-object icon icon-close pull-right'
        @subview 'search', new Fireahead 'Search', fb('tags'),
          (clicked) ->
            if clicked.name
              obj = {}
              obj[ clicked.name ] = { intended: true }
              fbref.update(obj)
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
        for tag in common_tags
          [ type, tagname ] = tag.split(': ')
          @li class: 'table-view-cell', tag: tag, =>
            @div =>
              @b tagname
              @p =>
                @text "I wanted this "
                @b type
            @button class: 'btn btn-positive', click: 'add', 'add'
        @div click: 'remover', outlet: 'removers'
  initialize: (item, engagement, @fbref, common_tags) ->
    @sub @fbref, 'value', (snap) =>
      tags = snap.val()
      @removers.html $$ ->
        if tags
          @li class: 'table-view-divider'
        for tag, data of tags
          [ type, tagname ] = tag.split(': ')
          @li class: 'table-view-cell', tag: tag, =>
            @div =>
              @b tagname
              @p =>
                @text "I wanted this "
                @b type
            @button class: 'btn btn-negative', 'remove'
  add: (event, element) =>
    obj = {}
    obj[ element.parent().attr 'tag' ] = { intended: true }
    @fbref.update(obj)
    $(element).parent().hide()
  remover: (event, element) =>
    tag = $(event.target).parent().attr 'tag'
    if tag
      @fbref.child(tag).remove()
