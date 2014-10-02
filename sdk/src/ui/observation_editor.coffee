class window.ObservationEditor extends Modal
  initialize: (@subvalue, @value, @delegate) ->
    @openIn(@delegate)
    @observe current_user, 'observations', @subvalue

  @options: [
    { icon: 'forward', exp: 'leadsto,1',       label: 'good for getting started' },
    { icon: 'check',   exp: 'satisfies,1',     label: 'good for every time'      },
    { icon: 'close',   exp: 'leadsto,0',       label: 'a distraction'            },
    { icon: 'more',    exp: 'evaluatingfor,1', label: 'don\'t know yet'          },
  ]
    
  @content: (subvalue, value, delegate) ->
    @div class: 'hovermodal outcomeChooser chilllozenges', =>
      @div class: 'content-padded', =>
        @h4 click: 'editValue', =>
          @text "How was "
          @raw subvalue.lozenge()
          @text " for "
          @raw value.lozenge()
          @text "?"
      @ul class: 'table-view card', =>
        for x in @options
          @li exp: x.exp, click: 'buttonClicked', class: 'table-view-cell media', =>
            @a =>
              @span class: "media-object pull-left icon icon-#{x.icon}"
              @div class: 'media-body', x.label
      @div click: "editValue", =>
        @raw "know something better? &raquo;"
  buttonClicked: (ev) =>
    exp = $(ev.target).pattr('exp')
    [ rel, val ] = exp.split(',')
    current_user.observes @subvalue, rel, @value, Number(val)
    @close()
    # setTimeout( (=> @close()), 100)
    switch
      when val < 0.5
        new BetterActivityCollector(@delegate, value: @value)
      when rel == 'leadsto'
        new KeyAssetCollector(@delegate, value: @value, provider: @subvalue)
  editValue: (ev) =>
    @parent.pushPage new ReasonEditor(@value)
    @close()

  observationsChanged: (ary) ->
    for e in ary
      if e[2] == @value.id
        switch e[1]
          when 'leadsto'
            if e[3] > 0.5
              @find('[exp="leadsto,1"]').addClassAmongSiblings('checked')
            else
              @find('[exp="leadsto,0"]').addClassAmongSiblings('checked')
          when 'satisfies'
            @find('[exp="satisfies,1"]').addClassAmongSiblings('checked') if e[3] > 0.5
          when 'evaluatingfor'
            @find('[exp="evaluatingfor,1"]').addClassAmongSiblings('checked') if e[3] > 0.5
