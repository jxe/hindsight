class SmileyView extends View
  initialize: (@db, @tag, tagname, @data) -> true

  # actions

  goingPoorly: ->
    if @data.going == 'poorly'
      @db.review.child(@tag).child('going').remove()
      @db.resource.fb('tags/%/going_poorly_for', @tag).remove_user()
    else
      @db.review.child(@tag).update going: 'poorly'
      @db.resource.fb('tags/%/going_well_for', @tag).remove_user()
      @db.resource.fb('tags/%/going_poorly_for', @tag).add_user()
      @db.resource.touch()

  goingWell: ->
    if @data.going == 'well'
      @db.review.child(@tag).child('going').remove()
      @db.resource.fb('tags/%/going_well_for', @tag).remove_user()
    else
      @db.review.child(@tag).update going: 'well'
      @db.resource.fb('tags/%/going_poorly_for', @tag).remove_user()
      @db.resource.fb('tags/%/going_well_for', @tag).add_user()
      @db.resource.touch()

  remove: (ev) ->
    @db.review.child(@tag).set(false)
    @db.resource.fb('tags/%/going_poorly_for', @tag).remove_user()
    @db.resource.fb('tags/%/going_well_for', @tag).remove_user()

  toggled: (ev) ->
    if $(ev.target).is '.active'
      obj = {}
      obj[ @tag ] = { intended: true }
      @db.review.update(obj)
    else
      @db.review.child(@tag).remove()


  # drawing

  @content: (db, tag, tagname, data) ->
    @ul class: 'table-view', =>
      @li class: 'table-view-divider', =>
        @text tagname
        if !data?.going
          @span click: 'remove', class: 'icon icon-close pull-right'
      @li class: 'table-view-cell', tag: tag, =>
        [ type, tagname ] = tag.split(': ')
        @div =>
          @p =>
            @text "I wanted this "
            @b type
        @div toggle: 'toggled', class: "toggle #{ 'active' if data }", =>
          @div class: 'toggle-handle'
      if data
        going = data.going
        @li class: 'table-view-cell how-going', =>
          @button click: 'goingWell', class: "btn-positive #{ if going != 'well' then 'btn-outlined' }", =>
            @raw '&#9786; '
            @text "Going well"
          @button click: 'goingPoorly', class: "btn-negative #{ if going != 'poorly' then 'btn-outlined'}", =>
            @raw '&#9785; '
            @text "Going poorly"
      if data?.going
        switch data.going
          when 'well'
            @goingWellContent(tagname, data)
          when 'poorly'
            @goingPoorlyContent(tagname, data)


  # these are just defaults to be overriden

  @goingWellContent: (tagname, data) ->
    @li class: 'table-view-cell', "Yay!"
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
