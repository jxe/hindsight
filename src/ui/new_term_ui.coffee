window.term_category = (name) ->
  return 'My being'     if name.match /feeling/
  return 'My lifestyle' if name.match /ing/
  return 'My stuff'     if name.match /^(a|the|some) /
  return 'My lifestyle'

class window.NewValueScreen extends Modal
  initialize: (@parent, @name, @cb) ->
    @openIn @parent
  @question: (type, prompt) ->
    @section class: 'question', =>
      @div class: 'prompt', prompt
      @div style: 'text-align:right', =>
        @button class: 'btn-positive', click: 'pick', chose: type, =>
          @span class: 'icon icon-right'
          @text 'It\'s this!'

  @content: (parent, name) ->
    console.log 'name', name
    initial_tab = term_category(name)
    console.log 'selectedTab', initial_tab
    @div class: 'hovermodal new_gift_wizard chilllozenges', =>
      @div class: 'content-padded', =>
        @p "You're adding a new value to our database! Help us classify it."
        @h4 style: 'padding-bottom: 15px', =>
          @span class: '-hsloz well', =>
            @span ''
            @b name
        @div "First, what's it about?"
        console.log 'selectedTab', initial_tab
        @tabs [ 'My lifestyle', 'My peeps', 'My stuff', 'My being' ], selectedTab: initial_tab, (tab) =>
          switch tab
            when 'My being'
              @question 'impression', "OK then, is it a feeling, like 'feeling relaxed'?"
              @question 'recognition', "Is it a virtue, like 'courage' or 'honesty?"
            when 'My lifestyle'
              @question 'activity', "OK, is it an activity, like 'skiing' or 'hanging with my friends?"
            when 'My peeps'
              @question 'equipment', "OK, is it about participating with others, like 'romance' or 'meaningful work'?"
            when 'My stuff'
              @question 'equipment', "OK, is it a physical asset, like 'a guitar' or category of asset, like 'transport'?"

  pick: (ev) =>
    @close()
    type = $(ev.target).pattr('chose')
    new_value = Good.create(type, @name)
    @parent.pushPage new ReasonEditor new_value, @cb
