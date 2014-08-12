class window.ReasonExperiencesEditor extends Page
  initialize: (@value, @resource) ->
    resource = @resource
    @value.onConcernState this, current_user_id, (concerned, succeeded) =>
      @find('.control-item').removeClass('active')
      if succeeded
        @find('.control-item.succeeding').addClass('active')
        @find('.successes').css('display', '')
      else
        @find('.control-item.notsucceeding').addClass('active')
        @find('.successes').css('display', 'none')
    @observe @value, 'onOutcomesChanged', current_user_id
     
              
  # filter by status and plug into the table
  onOutcomesChanged: (outcomes) ->
    @find(".resource-outcomes .control-item").removeClass('active')
    for outcome in ['delivered', 'helpedWith', 'abandonedFor', 'trying']
      if (outcomes[outcome] || []).indexOf(@resource.canonUrl) >= 0
        @find(".control-item.#{outcome}").addClass('active')
      @find(".section.#{outcome}").html $$ ->
        for x in outcomes[outcome] || [] 
          @li class: 'table-view-cell', x
  
  @content: (value, resource) ->
    @div =>
      @header class: 'bar bar-nav', =>
        @a class: 'icon icon-left-nav pull-left', click: 'back'
      @div class: 'content', =>
        @div class: 'content-padded', =>
          @h4 click: 'editReason', class: 'prompt', =>
            @raw value.successQuestion()
          @div class: 'segmented-control', =>
            @div class: 'control-item notsucceeding', click: 'notsucceeding', "No"
            @div class: 'control-item succeeding', click: 'succeeding', "Yes"
          @h4 class: 'prompt', "And #{resource.name()}..."
          @div class: 'segmented-control resource-outcomes', =>
            @div class: 'control-item successes delivered', click: 'delivered', value.deliveredHeading
            @div class: 'control-item helpedWith', click: 'helpedWith', value.helpedWithHeading
            @div class: 'control-item abandonedFor', click: 'abandonedFor', value.abandonedForHeading
            @div class: 'control-item trying', click: 'trying', value.tryingHeading
        @div class: 'table-view', =>
          @div class: 'successes', =>
            @li class: 'table-view-divider', value.deliveredHeading
            @div class: 'section delivered'
          @li class: 'table-view-divider', value.helpedWithHeading
          @div class: 'section helpedWith'
          @li class: 'table-view-divider', value.abandonedForHeading
          @div class: 'section abandonedFor'
          @li class: 'table-view-divider', value.tryingHeading
          @div class: 'section trying'
  
  editReason: ->
    @pushPage new ReasonEditor(@value)
  
  succeeding: =>
    @value.userIsSucceeding(current_user_id, true)

  notsucceeding: =>
    @value.userIsSucceeding(current_user_id, false)

  delivered: =>
    @resource.outcomeForUser(current_user_id, @value, "delivered")
  helpedWith: =>
    @resource.outcomeForUser(current_user_id, @value, "helpedWith")
  trying: =>
    @resource.outcomeForUser(current_user_id, @value, "trying")
  abandonedFor: =>
    @resource.outcomeForUser(current_user_id, @value, "abandonedFor")

             
              
#class SomethingElse extends Page
#  @content: (tag, tagname, thing) ->
#    @div class: 'something_else', =>
#      @header class: 'bar bar-nav', =>
#        @a class: 'icon icon-left-nav pull-left', click: 'back'
#      @div class: 'content', =>
#        @div class: 'content-padded', =>
#          @h4 class: 'prompt', =>
#            @text "What did you find that's better for "
#            @b tagname
#            @text " than "
#            @b thing
#            @text "?"
#          @p =>
#            @subview 'resource', new ResourcePicker 'Type a URL or search', fb('resources'), (r, rf) ->
#              return alert('unrecognized url') if r == 'error'
#              r.goingWellFor(window.current_user_id, tag)
#              rf.popPage().pop().push(ResourceExperienceEditor.fromResourceAndUser(r, window.current_user_id, true))


#  @goingWellContent: (type, tagname, data) ->
#    if type == 'activity'
#      @div =>
#        @li class: 'table-view-cell', =>
#          @p "Product helped me get started"
#          @div class: "toggle", =>
#            @div class: 'toggle-handle'
#        @li class: 'table-view-cell', =>
#          @p =>
#            @text "I do this "
#            @b outlet: 'how_often', "weekly"
#          @input type: 'range'
#    
#
#  @goingPoorlyContent: (type, tagname, data) ->
#    if type == 'activity'
#      @div =>
#        @li class: 'table-view-cell', =>
#          @p "Still desired?"
#          @div toggle: 'toggleDesired', class: "toggle", =>
#            @div class: 'toggle-handle'

 