class window.Feed extends View
  @content: (fbref) ->
    @div click: 'rowclick'

  who_reviewed: (rdata) ->
    user_ids = {}
    user_faces = []
    user_names = []
    for tag, data of rdata.tags
      for batch in [ data.going_well_for, data.going_poorly_for ]
        if batch
          for user, info of batch
            unless user_ids[user]
              user_names.push(info.name)
              user_faces.push("<img src='#{info.image}'/>")
              user_ids[user] = true
    return [user_faces.join(''), user_names.length]

  initialize: (@fbref) ->
    @sub @fbref.limit(50), 'value', (snap) =>
      @resources = resources = snap.val()
      self = this

      @html $$ ->
        urls = Object.keys(resources).reverse()
        for url in urls
          data = resources[url]
          @li url: data.url, class: 'table-view-cell media', =>
            [ faces, count ] = self.who_reviewed(data)
            @div class: 'facerow', =>
              @raw faces
            @img class: 'media-object pull-left', src: data.image
            @div class: "media-body", =>
              @b data.name
              @text " has "
              @b (if count > 1 then "#{count} reviews" else "one review")
              @subview 'label', new WarningLabel(data.tags)
              @p data.url

  rowclick: (ev) =>
    unless window.current_user_id
      batshit.please_login()
      return false
    url = $(ev.target).attr('url') || $(ev.target).parents('li').attr('url')
    window.open_review @resources[Links.asFirebasePath(url)]
