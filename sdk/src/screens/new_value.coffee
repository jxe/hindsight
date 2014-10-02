class window.NewValueScreen extends Modal
  initialize: (@parent, @name, @cb) ->
    @openIn @parent
  @content: (parent, name) ->
    initial_tab = switch name
      when /feeling/ then 'self'
      when /ing/ then 'activities'
      when /^(a|the|some) / then 'possessions'
      else 'activities'
    @div class: 'hovermodal NewValueScreen', =>
      @div class: 'content-padded', =>
        @input change: 'inputChanged', value: name, outlet: 'theInput'
        @h4 "You're adding a new value to our database! Help us classify it:  what's it about?"
      @tabs [ 'self', 'activities', 'relationships', 'possessions' ], selectedTab: initial_tab, (tab) =>
        switch tab
          when 'self'
            @h4 "Is it a feeling, like 'feeling relaxed'?"
            @button click: 'pick', chose: 'impression', 'Yes'
            @h4 "Is it a virtue, like 'courage' or 'honesty?"
            @button click: 'pick', chose: 'recognition', 'Yes'
          when 'activities'
            @h4 "Is it an activity, like 'skiing' or 'hanging with my friends?"
            @button click: 'pick', chose: 'activity', 'Yes'
          when 'relationships'
            @h4 "Is it about participating with others, like 'romance' or 'meaningful work'?"
            @button click: 'pick', chose: 'recognition', 'Yes'
          when 'possessions'
            @h4 "Is it a physical asset, like 'a guitar' or 'transport'?"
            @button click: 'pick', chose: 'equipment', 'Yes'

  pick: (ev) =>
    @close()
    type = $(ev.target).pattr('chose')
    new_value = Value.create(type, @name)
    @parent.pushPage new ReasonEditor new_value, @cb
 
  # inputChanged: (ev) =>
  #   @name = theInput.val()
  #   @updateSentences()
  # updateSentences: =>
  #   @accomplishment.html "#{@name} is something I do often"  # skiing
  #   @competance.html "It took #{name} to do what I did today" # courage
  #   @feeling.html "It's great to notice when I'm #{@name}" # feeling relaxed
  #   # @infrastructure.html "In order to be happy, people need #{@name} available to them"  # friends
  #   # @aesthetic.html "A room with #{@name} helps me feel good"  # simplicy
