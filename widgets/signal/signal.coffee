class window.Signal extends View
  @content: (resource_url, user_desires, common_desires, best_options, related_desires) ->
    top_desires = Desires.personalize(user_desires, common_desires)
    top_desire = top_desires.shift()
    @div class: 'hindsight-signal', =>
      @drawLabel top_desire, best_options[top_desire.id], related_desires[top_desire.id]
      if top_desires.length
        @span =>
          @raw "&bull;&bull;&bull; &#x25B6;"

  @drawLabel: (desire, best_options, related_desires) ->
    rating = Ratings.situate(desire, best_options)
    @div class: "hindsight-label #{rating}", click: 'openDreambox', =>
      @div class: 'fraction', =>
        @div class: 'numerator', =>
          @text "#{Ratings.label(rating)} "
          @i "for"
        @div class: 'denominator', =>
          @text desire.id.split(': ')[1]
          # if Desires.strong_migrations(related_desires)
          #   @img src: 'img/migrations-alert.png'

  @load_from_url: (url, cb) ->
    # TODO: use firebase instead
    s = new Signal(url, null, EXAMPLE_DATA.common_desires[url], EXAMPLE_DATA.best_options, EXAMPLE_DATA.related_desires)
    cb(s)

  @attach_to_divs: (product_selector, signal_selector) ->
    $ =>
      $(product_selector).each ->
        outer = $(this)
        url = outer.attr('url')
        Signal.load_from_url url, (signal) ->
          outer.find(signal_selector).html(signal)

  openDreambox: ->
    Dreambox.show()
    # alert('I love the world!')
