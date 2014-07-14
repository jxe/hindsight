class window.Dreambox extends Popover
  @content: (desire, best_options, related_desires) ->
    desire = "A QUICK BREAK"
    resource = "FACEBOOK"
    @div class: 'dreambox popover', =>
      @ul class: 'table-view', =>
        @li class: 'table-view-divider', =>
          @text "Similar to "
          @b desire
        @li class: 'table-view-cell', =>
          @subview 'signal', Signal.withOutcome('', id: 'activity: sunshine', going: 'well')
          @p "2 friends want this"
        @li class: 'table-view-cell', =>
          @subview 'signal', Signal.withOutcome('', id: 'activity: being creative', going: 'well')
          @p "2 events tonight, 15 activities"
        @li class: 'table-view-divider', =>
          @text "Better options"
        @li class: 'table-view-cell', =>
          @img class: 'media-object pull-left', src: '/img/random-app.jpg'
          @div class: 'media-body', =>
            @b "A walk outside"
            @p "3 nearby venues"
        @li class: 'table-view-cell', =>
          @img class: 'media-object pull-left', src: '/img/library.png'
          @div class: 'media-body', =>
            @b "Yoga"
            @p "3 videos"
        @li class: 'table-view-divider', =>
          @text "How "
          @b resource
          @text " stacks up:"
        @li class: 'table-view-cell', =>
          @img class: 'map', src: '/img/map-facebook-walk.png'
          # @p class: 'map', "awesome map here"
          # @p "time investment -->"
