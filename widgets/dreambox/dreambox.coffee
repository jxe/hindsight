class window.Dreambox extends Popover
  @content: (desire, best_options, related_desires) ->
    @div class: 'dreambox popover', =>
      @ul class: 'table-view', =>
        @li class: 'table-view-divider', =>
          @text "Fans of "
          @b "FEELING RELAXED"
          @text " later prefer"
        @li class: 'table-view-cell', =>
          @b "feeling loved"
          @p "2 friends want this"
        @li class: 'table-view-cell', =>
          @b "being creative"
          @p "2 events tonight, 15 activities"
        @li class: 'table-view-divider', =>
          @text "More options for "
          @b "FEELING RELAXED"
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
          @b "FACEBOOK"
          @text " stacks up:"
        @li class: 'table-view-cell', =>
          @img class: 'map', src: '/img/map-facebook-walk.png'
          # @p class: 'map', "awesome map here"
          # @p "time investment -->"
