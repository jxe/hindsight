class SmileyView extends View
  @smileys: (going) ->
    @div class:'smileys', =>
      @span click: 'goingPoorly', class: ('selected poorly' if going == 'poorly'), =>
        @raw '&#9785;'
      @span click: 'goingWell', class: ('selected well' if going == 'well'), =>
        @raw '&#9786;'
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
  initialize: (@fbref, @tag, tagname, @data) ->
    true
  @content: (fbref, tag, tagname, data) ->
    @div =>
      @li class: 'table-view-divider', =>
        @text tagname
        @smileys data.going
      if data.going
        switch data.going
          when 'well'
            @goingWellContent(tagname, data)
          when 'poorly'
            @goingPoorlyContent(tagname, data)
  @goingWellContent: (tagname, data) ->
    @p "yay!"
  @goingPoorlyContent: (tagname, data) ->
    @p "Sorry to hear it"



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
