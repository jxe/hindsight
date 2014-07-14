class window.Signal extends View
  @withGuess: (resource_url, user_desires, common_desires, best_options, related_desires) ->
    top_desires = Desires.personalize(user_desires, common_desires)
    for desire in top_desires
      desire.rating = Ratings.situate(desire, best_options[desire.id])
    new Signal(resource_url, top_desires)

  @withOutcomes: (resource_url, outcomes) ->
    outcomes_ary = []
    # console.log outcomes
    for outcome, data of outcomes
      if data
        data.rating = data.going || '?'
        data.id = outcome
        outcomes_ary.push data
    new Signal(resource_url, outcomes_ary)

  @withOutcome: (resource_url, data) ->
    if data.going_well_for
      data.going = 'well'
    else if data.going_poorly_for
      data.going = 'poorly'
    data.rating = data.going || '?'
    new Signal(resource_url, [data], true)

  initialize: (@resource_url) ->
  @content: (resource_url, outcomes, hide_tail) ->
    # console.log outcomes
    @div class: 'hindsight-signal', =>
      @drawLabel outcomes.shift()
      if !hide_tail # outcomes.length
        @div click: 'openReview', class: 'hindsight-lozenge trailer', =>
          @raw "&#x25B6;"

  @drawLabel: (desire) ->
    @div class: "hindsight-lozenge #{desire.rating}", click: 'openDreambox', =>
      @span class: 'gem'
      @span class: 'text', =>
        @b "#{desire.id.split(': ')[1]}"
        @raw '&nbsp;'
        @span Ratings.label(desire.rating)
          # if Desires.strong_migrations(related_desires)
          #   @img src: 'img/migrations-alert.png'

  @load_from_url: (url, cb) ->
    # TODO: use firebase instead
    s = Signal.withGuess(url, null, EXAMPLE_DATA.common_desires[url], EXAMPLE_DATA.best_options, EXAMPLE_DATA.related_desires)
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

  openReview: ->
    Review.open_url(this, @resource_url)
