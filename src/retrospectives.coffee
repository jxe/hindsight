class SmileyView extends View
  @smileys: (going) ->
    @div class:'smileys', =>
      if going
        @span click: 'goingPoorly', class: ('selected poorly' if going == 'poorly'), =>
          @raw '&#9785;'
        @span click: 'goingWell', class: ('selected well' if going == 'well'), =>
          @raw '&#9786;'
      else
        @span click: 'remove', =>
          @span class: 'icon icon-close'
  goingPoorly: ->
    if @data.going == 'poorly'
      @fbref.child(@tag).child('going').remove()
    else
      @fbref.child(@tag).update going: 'poorly'
  goingWell: ->
    if @data.going == 'well'
      @fbref.child(@tag).child('going').remove()
    else
      @fbref.child(@tag).update going: 'well'
  remove: (ev) ->
    @fbref.child(@tag).set(false)
  toggled: (ev) ->
    if $(ev.target).is '.active'
      obj = {}
      obj[ @tag ] = { intended: true }
      @fbref.update(obj)
    else
      @fbref.child(@tag).remove()
  initialize: (@fbref, @tag, tagname, @data) ->
    true
  @content: (fbref, tag, tagname, data) ->
    @ul class: 'table-view', =>
      @li class: 'table-view-divider', =>
        @text tagname
        @smileys data?.going
      @li class: 'table-view-cell', tag: tag, =>
        [ type, tagname ] = tag.split(': ')
        @div =>
          @p =>
            @text "I wanted this "
            @b type
        @div toggle: 'toggled', class: "toggle #{ 'active' if data }", =>
          @div class: 'toggle-handle'
      if data?.going
        switch data.going
          when 'well'
            @goingWellContent(tagname, data)
          when 'poorly'
            @goingPoorlyContent(tagname, data)
      else if data
        @li class: 'table-view-cell', =>
          @button click: 'goingWell', class: 'btn-positive', "Going well"
          @button click: 'goingPoorly', class: 'btn btn-negative', "Going poorly"
      else

  @goingWellContent: (tagname, data) ->
    @li class: 'table-view-cell', "yay!"
  @goingPoorlyContent: (tagname, data) ->
    @li class: 'table-view-cell', "Sorry to hear it"



class window.ActivityResults extends SmileyView
  @goingWellContent: (tagname, data) ->
    @li class: 'table-view-cell', =>
      @p =>
        @text "I do this "
        @b outlet: 'how_often', "weekly"
      @input type: 'range'
    @li class: 'table-view-cell', =>
      @text "Product helped me get started"
      @div class: "toggle", =>
        @div class: 'toggle-handle'


class window.OutcomeResults extends SmileyView



class window.EthicResults extends SmileyView
