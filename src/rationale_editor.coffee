class window.RationaleEditor extends Modal
  @content: (item, engagement, fbref, common_tags) ->
    @div class: 'modal rationale_editor', =>
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
  remover: (event, element) =>
    tag = $(event.target).parent().attr 'tag'
    if tag
      @fbref.child(tag).remove()
