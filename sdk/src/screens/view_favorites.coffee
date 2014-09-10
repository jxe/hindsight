class window.PersonExperiencesInspector extends Page
  initialize: ->
    @observe Someone.usingThis(), 'onFavorites'
  
  onFavorites: (map) ->
    # value / attributes / subvalue / true
    @find('.values').html $$ ->
      for value, attributes of map
        did_draw_divider = false
        v = Value.fromId(value)
        for attr, subvalues of attributes
          if attr in [ 'hasLeadIns', 'hasWaysOfDoing' ]
            for subvalue, _ of subvalues
              sv = Value.fromId(subvalue)
              if !did_draw_divider
                @li class: 'table-view-divider', =>
                  @raw v.lozenge(attr)
                did_draw_divider = true
              @li class: 'table-view-cell', =>
                @text attr
                @raw " "
                @raw sv.lozenge()
  
  @content: ->
    @div class: 'concerns_view', =>
      @header class: 'bar bar-nav', =>
        @a class: 'icon icon-left-nav pull-left', click: 'back'
        @h1 class: 'title', "My Wisdom"
      @div class: 'content', =>
        @div class: 'table-view values'
