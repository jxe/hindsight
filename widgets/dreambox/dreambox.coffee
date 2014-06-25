class window.Dreambox extends Popover
  @content: (desire, best_options, related_desires) ->
    @div class: 'dreambox popover', =>
      @ul class: 'table-view', =>
        @li class: 'table-view-divider', =>
          @text "Fans of "
          @b "MINDLESS READING"
          @text " later prefer"
        @li class: 'table-view-cell', =>
          @b "being bold"
          @p "3 events tonight"
        @li class: 'table-view-cell', =>
          @b "being creative"
          @p "2 events"
        @li class: 'table-view-divider', =>
          @text "More options for "
          @b "MINDLESS READING"
        @li class: 'table-view-cell', =>
          @img class: 'media-object pull-left', src: '/img/random-app.jpg'
          @div class: 'media-body', =>
            @b "Random App"
            @p "less addictive, higher satisfaction"
        @li class: 'table-view-cell', =>
          @img class: 'media-object pull-left', src: '/img/library.png'
          @div class: 'media-body', =>
            @b "Your local library"
            @p "synergistic satisfier"
        @li class: 'table-view-divider', =>
          @text "How "
          @b "FACEBOOK"
          @text " stacks up:"
        @li class: 'table-view-cell', =>
          @p class: 'map', "awesome map here"
