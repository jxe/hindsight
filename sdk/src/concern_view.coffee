class window.ReasonExperiencesEditor extends Page
  initialize: (@value, @resource) ->
    resource = @resource
    @observe @value, 'onConcernState', current_user_id
    @observe Someone.usingThis(), 'onResourceOutcomes', reason: @value.id
  
  onConcernState: (obj) ->
    @succeeding = obj?.navigable
    @find('.control-item').removeClass('active')
    if @succeeding
      @find('.control-item.succeeding').addClass('active')
    else
      @find('.control-item.notsucceeding').addClass('active')
    @configure()
  
  onResourceOutcomes: (data) =>
    @outcomes.empty()
    for resource_url, outcomes_data of data
      if resource_url == @resource.canonUrl
        @currentExperience = @value.summarize(outcomes_data)
      heading = @value.headingFor(outcomes_data)
      @outcomes.append $$ ->
        @li class: 'table-view-cell', "#{resource_url} #{heading}"
    @configure()
#    @find(".resource-outcomes .control-item").removeClass('active')
#      if (outcomes[outcome] || []).indexOf(@resource.canonUrl) >= 0
#        @find(".control-item.#{outcome}").addClass('active')

  
  configure: =>
    @currentExperience ||= 'trying'
    @experienceOptions.empty()
    labels = @value.experienceOptionHeadings()
    for type in @value.experienceOptionsForKnowsHow(@succeeding)
      continue if type == @currentExperience
      @experienceOptions.append do (type) =>
        option = $$ -> @div class: 'control-item', labels[type]
        option.click => @selectedExperienceOption(type)
    @currentExperienceSlot.html labels[@currentExperience]

  selectedExperienceOption: (name) =>
    console.log 'selected', name
    outcomes = @value.experienceOptions[name]
    @resource.outcomesForUser(current_user_id, @value, outcomes)

  @content: (value, resource) ->
    @div class: 'concern_view', =>
      @header class: 'bar bar-nav', =>
        @a class: 'icon icon-left-nav pull-left', click: 'back'
      @div class: 'content', =>
        @div class: 'content-padded', =>
          @h4 click: 'editReason', class: 'prompt', =>
            @raw value.successQuestion()
          @div class: 'segmented-control', =>
            @div class: 'control-item notsucceeding', click: 'is_not_succeeding', "No"
            @div class: 'control-item succeeding', click: 'is_succeeding', "Yes"
          @h4 class: 'sentence', =>
            @text "And #{resource.name()} "
            @b outlet: 'currentExperienceSlot', 'is under review'
          @div outlet: 'experienceOptions', class: 'segmented-control'
        @div outlet: 'outcomes', class: 'table-view'
        @subview 'resourcePicker', new ResourcePicker hint: 'What\'s good for this?'
  
  onChoseResource: (r) =>
    return alert('unrecognized url') if r == 'error'
    alert 'todo'
#    r.outcomesForUser(current_user_id, @value, @value.experienceOptions.key)
    
  editReason: ->
    @pushPage new ReasonEditor(@value)
  
  is_succeeding: =>
    @value.userIsSucceeding(current_user_id, true)

  is_not_succeeding: =>
    @value.userIsSucceeding(current_user_id, false)


             
              
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

 