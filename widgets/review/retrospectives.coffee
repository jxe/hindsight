class Outcome extends View
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
    this.parents('.pager_viewport').view().pop();
    return false
  
  back: ->
    this.parents('.pager_viewport').view().pop();
    return false

  toggleDesired: (ev) ->
    if $(ev.target).is '.active'
      @db.desires.child(@tag).update still_desired: true
    else
      @db.desires.child(@tag).update still_desired: false

  # drawing

  @content: (db, tag, tagname, data) ->
    [ type, tagname ] = tag.split(': ')
    @ul class: 'table-view card', =>
      if data
        going = data.going
        @li class: 'table-view-cell', click: 'back', 'Back'
        @li class: 'table-view-cell', click: 'remove', 'Remove'
        @li class: 'table-view-cell signalrow', tag: tag, =>
          @subview 'signal', Signal.withOutcome('..', data || { id: tag })
        @li class: 'table-view-cell segmentrow', =>
          @div class: 'segmented-control', =>
            @a click: 'goingPoorly', class: "red control-item  #{ if going == 'poorly' then 'active' }", =>
              @text "Going poorly"
            @a click: 'goingWell', class: "green control-item  #{ if going == 'well' then 'active' }", =>
              @text "Going well"
      if data?.going
        switch data.going
          when 'well'
            @goingWellContent(type, tagname, data)
          when 'poorly'
            @goingPoorlyContent(type, tagname, data)


  @goingWellContent: (type, tagname, data) ->
    if type == 'activity'
      @div =>
        @li class: 'table-view-cell', =>
          @p "Product helped me get started"
          @div class: "toggle", =>
            @div class: 'toggle-handle'
        @li class: 'table-view-cell', =>
          @p =>
            @text "I do this "
            @b outlet: 'how_often', "weekly"
          @input type: 'range'
    

  @goingPoorlyContent: (type, tagname, data) ->
    if type == 'activity'
      @div =>
        @li class: 'table-view-cell', =>
          @p "Still desired?"
          @div toggle: 'toggleDesired', class: "toggle", =>
            @div class: 'toggle-handle'

