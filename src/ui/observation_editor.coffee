class window.ObservationEditor extends MenuModal
  initialize: (@subvalue, @value, @delegate) ->
    @openIn(delegate)
    @prompt.html $$ ->
      @div =>
        @text "How was "
        @raw subvalue.lozenge()
        @text " for "
        @raw value.lozenge()
        @text "?"
    @footerView.html $$ ->
      @div =>
        @raw "know something better? &raquo;"

  @options: [
    ['leadsto,1', 'good for getting started', 'forward'],
    ['satisfies,1', 'good for every time', 'check'],
    ['leadsto,0', 'a distraction', 'close'],
    ['whatdrives,1', 'don\'t know yet', 'more']
  ]
    
  clicked: (ev) =>
    exp = $(ev.target).pattr('id')
    [ rel, val ] = exp.split(',')
    current_user.observes @subvalue, rel, @value, Number(val)
    @close()
    # setTimeout( (=> @close()), 100)
    switch
      when val < 0.5
        new BetterActivityCollector(@delegate, value: @value)
      when rel == 'leadsto'
        new KeyAssetCollector(@delegate, value: @value, provider: @subvalue)
  footerClicked: (ev) =>
    @parent.pushPage new ReasonEditor(@value)
    @close()
