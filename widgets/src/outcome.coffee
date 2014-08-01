class SomethingElse extends Page
  @content: (tag, tagname, thing) ->
    @div class: 'something_else', =>
      @header class: 'bar bar-nav', =>
        @a class: 'icon icon-left-nav pull-left', click: 'back'
      @div class: 'content', =>
        @div class: 'content-padded', =>
          @h4 class: 'prompt', =>
            @text "What did you find that's better for "
            @b tagname
            @text " than "
            @b thing
            @text "?"
          @p =>
            @subview 'resource', new ResourceField 'Type a URL or search', fb('resources'), (r, rf) ->
              return alert('unrecognized url') if r == 'error'
              r.goingWellFor(window.current_user_id, tag)
              rf.parents('.pager_viewport').view().pop().pop().push(Review.fromResourceAndUser(r, window.current_user_id, true))


class Outcome extends View
  initialize: (@db, @tag, @tagname, @data, @thing) -> true

  @content: (db, tag, tagname, data, thing) ->
    @div =>
      @header class: 'bar bar-nav', =>
        @a class: 'icon icon-left-nav pull-left', click: 'back'
        @button class: 'btn pull-right', click: 'back', 'Done'
      @div class: 'bar bar-standard bar-footer', =>
        @a class: 'icon icon-trash pull-right', click: 'remove'
      @div class: 'content', =>
        @div class: 'content-padded', =>
          @h4 class: 'prompt', =>
            @text "How is it going with "
            @b tagname
            @text "?"
          @p =>
            @button class: 'btn btn-positive btn-block', click: 'goingWell', "#{ thing } was what I needed!"
            @button class: 'btn btn-negative btn-block', click: 'goingPoorly', "#{ thing } didn't help, still looking!"
            @button class: 'btn btn-positive btn-outlined btn-block', click: 'somethingElse', "I found something else"
            @button class: 'btn btn-negative btn-outlined btn-block', click: 'goingPoorly', "I gave up"
          
#          going = data.going
#          @li class: 'table-view-cell signalrow', tag: tag, =>
#            @subview 'signal', Signal.withOutcome('..', data || { id: tag })
# 
#          switch data?.going
#            when 'well'
#              @goingWellContent(type, tagname, data)
#            when 'poorly'
#              @goingPoorlyContent(type, tagname, data)

  
  # actions
  somethingElse: =>
    this.parents('.pager_viewport').view().push(new SomethingElse(@tag, @tagname, @thing));
    
  goingPoorly: =>
    if @data.going != 'poorly'
      @db.outcomes.child(@tag).update going: 'poorly'
      @db.resource.fb('tags/%/going_well_for', @tag).remove_user()
      @db.resource.fb('tags/%/going_poorly_for', @tag).add_user()
      @db.engagement.update type: 'used'
      @db.resource.touch()
    this.parents('.pager_viewport').view().pop();

  goingWell: =>
    if @data.going != 'well'
      @db.outcomes.child(@tag).update going: 'well'
      @db.resource.fb('tags/%/going_poorly_for', @tag).remove_user()
      @db.resource.fb('tags/%/going_well_for', @tag).add_user()
      @db.engagement.update type: 'used'
      @db.resource.touch()
    this.parents('.pager_viewport').view().pop();

  remove: (ev) ->
    return unless confirm('Sure?')
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

