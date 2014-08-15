class window.PersonExperiencesInspector extends Page
  initialize: ->
    @observe Someone.usingThis(), 'onResourceOutcomes', skip_abandoned: true
  
  onResourceOutcomes: (map) ->
    # value / resource / outcome_data
    @find('.values').html $$ ->
      for value, resources_data of outcomes
        did_draw_divider = false
        v = Reason.fromId(value)
        for resource, outcome_summary of resources_data
          r = Resource.fromUrlWithoutMetadata(resource)
          if !did_draw_divider
            @li class: 'table-view-divider', =>
              @raw v.lozenge(outcome_summary)
            did_draw_divider = true
          @li class: 'table-view-cell', =>
            @b r.name()
            @raw " "
            @text outcome_summary
      
  @content: ->
    @div class: 'concerns_view', =>
      @header class: 'bar bar-nav', =>
        @a class: 'icon icon-left-nav pull-left', click: 'back'
        @h1 class: 'title', "Value-aligned websites"
      @div class: 'content', =>
        @div class: 'table-view values'
