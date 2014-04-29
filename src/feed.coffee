class window.Feed extends View
  @content: (fbref) ->
    @ol class: 'table-view', click: 'rowclick'

  initialize: (@fbref) ->
    @sub @fbref, 'value', (snap) =>
      @resources = resources = snap.val()

      @html $$ ->
        for url, data of resources
          @li url: data.url, class: 'table-view-cell media', =>
            @img class: 'media-object pull-left', src: data.image
            @div class: "media-body", =>
              @text data.url
              @p data.name

  rowclick: (ev) =>
    unless window.current_user_id
      batshit.please_login()
      return false
    url = $(ev.target).attr('url') || $(ev.target).parents('li').attr('url')
    window.open_review @resources[Links.asFirebasePath(url)]
