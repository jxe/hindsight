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
    initial_tab = switch name
      when /feeling/ then 'My being'
      when /ing/ then 'My lifestyle'
      when /^(a|the|some) / then 'My stuff'
      else 'My lifestyle'
    @div class: 'hovermodal new_gift_wizard chilllozenges', =>
      @div class: 'content-padded', =>
        @p "You're adding a new value to our database! Help us classify it."
        @h4 style: 'padding-bottom: 15px', =>
          @span class: '-hsloz well', =>
            @span ''
            @b name
        @div "First, what's it about?"
        @tabs [ 'My lifestyle', 'My peeps', 'My stuff', 'My being' ], selectedTab: initial_tab, (tab) =>
          switch tab
            when 'My being'
              @question 'impression', "OK, is it a feeling, like 'feeling relaxed'?"
              @question 'recognition', "Is it a virtue, like 'courage' or 'honesty?"
            when 'My lifestyle'
              @question 'activity', "OK, is it an activity, like 'skiing' or 'hanging with my friends?"
            when 'My peeps'
              @question 'recognition', "OK, is it about participating with others, like 'romance' or 'meaningful work'?"
            when 'My stuff'
              @question 'equipment', "OK, is it a physical asset, like 'a guitar' or category of asset, like 'transport'?"

  pick: (ev) =>
    @close()
    type = $(ev.target).pattr('chose')
    new_value = Good.create(type, @name)
    @parent.pushPage new ReasonEditor new_value, @cb
