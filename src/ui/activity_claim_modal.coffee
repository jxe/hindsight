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
      ['implements,1', "<b>It's part of it.</b> #{@bloz} is part of #{@aloz}.", 'list']
    ]


class window.ActivityClaimModal extends Modal
  initialize: (@b, @a, @delegate) ->
    @openIn(delegate)
    @bind observationsChanged: Observations.live(current_user_id, @a)

  @content: (b, a) ->
    [ aloz, bloz ] = [ a.lozenge(), b.lozenge() ]
    @div class: 'hovermodal', =>
      @div class: 'content-padded', =>
         @p =>
            @raw "Is #{bloz} good for #{aloz}?"
         @segment 'goodFor', {yes:'Yes', no:'No', unknown:'Dont know yet'}, 'unknown'
         @p click: 'goal', =>
            @raw "How's your search for #{aloz}, generally?"
         @segment 'search', {enjoying:'Solved', seeking:'Still looking', abandoned:'Moved on'}, 'seeking'
         @div outlet: 'thirdQuestion'

  goal: =>
    @parent.pushPage new ReasonEditor(@a)
    @close()

  goodForChanged: (picked) =>
     @goodFor = picked
     console.log "gfc: perusal: ", @perusal, "goodfor", @goodFor
     current_user.thinksIsGoodFor(@b, @a, picked)
     # @redisplay()

  searchChanged: (picked) =>
     @perusal = picked
     console.log "sc: perusal: ", @perusal, "goodfor", @goodFor
     # @redisplay()
     current_user.setPerusalState(@a, @perusal)

  observationsChanged: (o) ->
    @perusal = o.pursualState(@a)
    @goodFor = o.isGoodFor(@b)
    console.log "oc: perusal: ", @perusal, "goodfor", @goodFor
    @redisplay()

  redisplay: =>
     @find("[tabname='#{@goodFor}']").addClassAmongSiblings('active')
     @find("[tabname='#{@perusal}']").addClassAmongSiblings('active')

     if @perusal == 'enjoying' and @goodFor == 'no'
        # what solved?
     else if @perusal == 'abandoned'
        # what's the new goal?
     else
        @thirdQuestion.empty()

  afterClick: (rel, val) =>
    if val < 0.5
      new BetterActivityCollector(@delegate, value: @a)
    else if @which == 'abandoned'
      new MoreImportantGoodCollector(@delegate, value: @a)

      
class window.MoreImportantGoodCollector extends Modal
  initialize: (@justifier, @options) ->
    @justifier.prompt "What is more important to you now than #{@options.value.lozenge()}?", =>
      @openIn(@justifier)
  @content: (justifier, options) ->
    @div class: 'hovermodal chilllozenges MoreImportantGoodCollector', =>
      @div class: 'content-padded', =>
        @h4 =>
          @raw "Add a goal that trumps #{options.value.lozenge()}"
      @subview 'search', new ReasonPicker(hint: "add a goal...")
  onChoseValue: (v) =>
    current_user.observes v, "trumps", @options.value, 1.0
    @close()
    @justifier.thanks()

class window.BetterActivityCollector extends Modal
  initialize: (@justifier, @options) ->
    @justifier.prompt "What does help, with #{@options.value.lozenge()}?", =>
      @openIn(@justifier)
  @content: (justifier, options) ->
    @div class: 'hovermodal chilllozenges BetterActivityCollector', =>
      @div class: 'content-padded', =>
        @h4 =>
          @raw "Add a better activity for #{options.value.lozenge()}"
      @subview 'search', new ReasonPicker(hint: "add an activity...")
  onChoseValue: (v) =>
    current_user.observes v, "delivers", @options.value, 1.0
    @close()
    @justifier.thanks()

