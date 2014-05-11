class window.Feed extends View
  @content: (fbref) ->
    @div click: 'rowclick'

  who_reviewed: (rdata) ->
    user_ids = {}
    user_names = []
    for tag, data of rdata.tags
      if data.going_well_for
        for user, info of data.going_well_for
          user_names.push(info.name) unless user_ids[user]
          user_ids[user] = true
      if data.going_poorly_for
        for user, info of data.going_poorly_for
          user_names.push(info.name) unless user_ids[user]
          user_ids[user] = true
    return user_names.join(', ')

  initialize: (@fbref) ->
    @sub @fbref.limit(50), 'value', (snap) =>
      @resources = resources = snap.val()
      self = this

      @html $$ ->
        urls = Object.keys(resources).reverse()
        for url in urls
          data = resources[url]
          @li url: data.url, class: 'table-view-cell media', =>
            @img class: 'media-object pull-left', src: data.image
            @div class: "media-body", =>
              @b self.who_reviewed(data)
              @text " reviewed "
              @b data.name
              @subview 'label', new WarningLabel(data.tags)
              @p data.url

  rowclick: (ev) =>
    unless window.current_user_id
      batshit.please_login()
      return false
    url = $(ev.target).attr('url') || $(ev.target).parents('li').attr('url')
    window.open_review @resources[Links.asFirebasePath(url)]
