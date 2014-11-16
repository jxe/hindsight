class window.ObservationMenu extends MenuModal
  initialize: ->
    [ @aloz, @bloz ] = [ @a.lozenge(), @b.lozenge() ]
    super()
  clicked: (ev) =>
    exp = $(ev.target).pattr('id')
    [ rel, val ] = exp.split(',')
    current_user.observes @b, rel, @a, Number(val)
    @close()
    @afterClick(rel, val) if @afterClick



class window.GoodObservationMenu extends ObservationMenu
  initialize: (@b, @a, @rel) ->
    super()
    @prompt.html "Why do people turn to #{@bloz} for #{@aloz}?"

  options: => 
    [
      ['delivers,1', "<b>It works.</b>. I've found #{@bloz} works for #{@aloz}.", 'check'],
      ['whatcomprisedof,1', "<b>It's part of it.</b> #{@bloz} is part of #{@aloz}.", 'list']
    ]



class window.EngagementObservationMenu extends ObservationMenu
  initialize: (@b, @a, @delegate) ->
    super()
    @prepend "
      <div class='editableStatement'>
        You're
        <span class='disposition'></span>
        <span class='loz'>#{@aloz}</span>
      </div>
    "
    @prompt.html "<p>How was #{@bloz} for this?</p>"
    @pstate = new WordChoice(null, ['seeking', 'happy with', 'done with'], this, 'pursualState')
    @find('.disposition').append @pstate
    @find('.loz').click => 
      @parent.pushPage new ReasonEditor(@a)
      @close()
    @openIn(delegate)
    @bind observationsChanged: Observations.live(current_user_id, @a)

  pursualStateChanged: (state) =>
    current_user.setPerusalState(@a, state)

  observationsChanged: (o) ->
    @pstate.setWord(o.pursualState(@a))

  options: => [
    ['delivers,1', 'good for this', 'check'],
    ['delivers,0', 'a distraction', 'close'],
    ['whatdrives,1', 'don\'t know yet', 'more']
  ]
    
  afterClick: (rel, val) =>
    if val < 0.5
      new BetterActivityCollector(@delegate, value: @a)
    else if @which == 'abandoned'
      new MoreImportantGoodCollector(@delegate, value: @a)

  promptClicked: (ev) =>
    true
