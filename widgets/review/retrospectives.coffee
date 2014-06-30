class SmileyView extends View
  initialize: (@db, @tag, tagname, @data) -> true

  # actions

  goingPoorly: ->
    if @data.going == 'poorly'
      @db.outcomes.child(@tag).child('going').remove()
      @db.resource.fb('tags/%/going_poorly_for', @tag).remove_user()
    else
      @db.outcomes.child(@tag).update going: 'poorly'
      @db.resource.fb('tags/%/going_well_for', @tag).remove_user()
      @db.resource.fb('tags/%/going_poorly_for', @tag).add_user()
      @db.engagement.update type: 'used'
      @db.resource.touch()

  goingWell: ->
    if @data.going == 'well'
      @db.outcomes.child(@tag).child('going').remove()
      @db.resource.fb('tags/%/going_well_for', @tag).remove_user()
    else
      @db.outcomes.child(@tag).update going: 'well'
      @db.resource.fb('tags/%/going_poorly_for', @tag).remove_user()
      @db.resource.fb('tags/%/going_well_for', @tag).add_user()
      @db.engagement.update type: 'used'
      @db.resource.touch()

  remove: (ev) ->
    @db.outcomes.child(@tag).set(false)
    @db.resource.fb('tags/%/going_poorly_for', @tag).remove_user()
    @db.resource.fb('tags/%/going_well_for', @tag).remove_user()

  toggled: (ev) ->
    if $(ev.target).is '.active'
      obj = {}
      obj[ @tag ] = { intended: true }
      @db.outcomes.update(obj)
    else
      @db.outcomes.child(@tag).remove()


  # drawing

  @content: (db, tag, tagname, data) ->
    @div =>
      @div class: 'content-padded', =>
        @h5 class: '', =>
          @text tagname
          if !data?.going
            @span click: 'remove', class: 'icon icon-close'
          @div toggle: 'toggled', class: "pull-right toggle #{ 'active' if data }", =>
            @div class: 'toggle-handle'
        if data
          going = data.going
          @div class: 'segmented-control', =>
            @a click: 'goingPoorly', class: "red control-item  #{ if going == 'poorly' then 'active' }", =>
              @raw '&#9785; '
              @text "Going poorly"
            @a click: 'goingWell', class: "green control-item  #{ if going == 'well' then 'active' }", =>
              @raw '&#9786; '
              @text "Going well"
      if data?.going
        switch data.going
          when 'well'
            @goingWellContent(tagname, data)
          when 'poorly'
            @goingPoorlyContent(tagname, data)


  # these are just defaults to be overriden

  @goingWellContent: (tagname, data) ->
    # @ul class: 'table-view', =>
    #   @li class: 'table-view-cell', "Yay!"
  @goingPoorlyContent: (tagname, data) ->
    # @ul class: 'table-view', =>
    #   @li class: 'table-view-cell', "Sorry to hear it"



class window.ActivityResults extends SmileyView
  @goingWellContent: (tagname, data) ->
    @ul class: 'table-view card', =>
      @li class: 'table-view-cell', =>
        @p "Product helped me get started"
        @div class: "toggle", =>
          @div class: 'toggle-handle'
      @li class: 'table-view-cell', =>
        @p =>
          @text "I do this "
          @b outlet: 'how_often', "weekly"
        @input type: 'range'
  @goingPoorlyContent: (tagname, data) ->
    @ul class: 'table-view card', =>
      @li class: 'table-view-cell', =>
        @p "Still desired?"
        @div toggle: 'toggleDesired', class: "toggle", =>
          @div class: 'toggle-handle'
  toggleDesired: (ev) ->
    if $(ev.target).is '.active'
      @db.desires.child(@tag).update still_desired: true
    else
      @db.desires.child(@tag).update still_desired: false


class window.OutcomeResults extends SmileyView



class window.EthicResults extends SmileyView
