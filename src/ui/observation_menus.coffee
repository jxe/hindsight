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
      ['whatincorporates,1', "<b>It's part of it.</b> #{@bloz} is part of #{@aloz}.", 'list']
    ]



class window.EngagementObservationMenu extends ObservationMenu
  initialize: (@b, @a, @delegate) ->
    super()
    @prompt.html "
      <div class='loz'>#{@aloz}</div>
      <div class='disposition'></div>
      <div style='display:none' class='menu'>
        <div which='sought'>I want this</div>
        <div which='handled'>I'm all set with this</div>
        <div which='abandoned'>I've moved on to more important things</div>
      </div>
      <p>How was #{@bloz} for this?</p>
    "
    @prompt.find('.disposition').click => @prompt.find('.menu').toggle()
    @prompt.find('.loz').click => 
      @parent.pushPage new ReasonEditor(@a)
      @close()
    @prompt.find('.menu').click (e) =>
      @which = $(e.target).pattr('which')
      current_user.setPerusalState(@a, @which)
    @openIn(delegate)
    @bind observationsChanged: Observations.live(current_user_id, @a)
  
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

  observationsChanged: (o) ->
    state = o.pursualState(@a)
    @prompt.find('.disposition').html switch state
      when 'sought' then 'I want this'
      when 'handled' then 'I\'m all set with this'
      when 'abandoned' then 'I\'ve moved on'
