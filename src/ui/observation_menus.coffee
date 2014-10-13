class window.ObservationMenu extends MenuModal
  initialize: ->
    [ @aloz, @bloz ] = [ @a.lozenge(), @b.lozenge() ]
    super()
  clicked: (ev) =>
    console.log 'ObservationMenu::clicked()'
    exp = $(ev.target).pattr('id')
    [ rel, val ] = exp.split(',')
    current_user.observes @b, rel, @a, Number(val)
    @close()
    @afterClick() if @afterClick



class window.GoodObservationMenu extends ObservationMenu
  initialize: (@b, @a) ->
    super()
    @prompt.html "Why do people turn to #{@bloz} for #{@aloz}?"

  options: => [
    ['leadsto,1', "<b>It works eventually.</b>. I've found that #{@bloz} eventually leads to #{@aloz}.", 'more'],
    ['quenches,1', "<b>It works immediately.</b> I've found that #{@bloz} routinely satisfies my desire to #{@aloz}.", 'check'],
    ['whatrequires,1', "<b>It's impossible otherwise.</b> No one could have #{@aloz} without #{@bloz}.", 'plus']
  ]



class window.EngagementObservationMenu extends ObservationMenu
  initialize: (@b, @a, @delegate) ->
    super()
    @prompt.html "How was #{@bloz} for #{@aloz}?"
    @openIn(delegate)
  
  options: => [
    ['leadsto,1', 'good for getting started', 'forward'],
    ['quenches,1', 'good for every time', 'check'],
    ['leadsto,0', 'a distraction', 'close'],
    ['whatdrives,1', 'don\'t know yet', 'more']
  ]
    
  afterClick: (ev) =>
    if val < 0.5
      new BetterActivityCollector(@delegate, value: @a)
    else if rel == 'leadsto'
      new KeyAssetCollector(@delegate, value: @a, provider: @b)

  promptClicked: (ev) =>
    @parent.pushPage new ReasonEditor(@a)
    @close()

