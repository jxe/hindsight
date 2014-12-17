class window.Observations
  @live: (guy, value) ->
    goods = observations = null
    new Stream (s) ->
      s.listen 'value', fb('terms/%', value.id), (snap) ->
        goods = snap.val() || {}
        s.emit new Observations(value, goods, observations) if observations
      s.listen 'value', fb('claims/%', guy), (snap) ->
        observations = snap.val() || {}
        s.emit new Observations(value, goods, observations) if goods

  # joe/asset:car/
  #   whattrumps/activity:creative projects/1.0
  #   desired/'on 1023980123'

  constructor: (@value, @connections, @observations) ->
    @relatives = {}
    @aliases = (if @connections.aliases then Object.keys @connections.aliases else [])
    delete @connections.aliases
    related_observations = observations[value.id] || {}
    for obj in [@connections, related_observations]
      for rel, v of obj
        if pojo(v)
          (@relatives[x] ||= {})[rel] = num for x, num of v

  # types of observations

  directObservations: ->
    item for item in Object.keys(@relatives) when @isDirectObservation(item)
  whyObservations: ->
    item for item in Object.keys(@relatives) when @isWhyObservation(item)
  howObservations: ->
    item for item in Object.keys(@relatives) when @isHowObservation(item)
  isDirectObservation: (x) ->
    it = @relatives[x]
    it.promises? or it.delivers?
  isWhyObservation: (x) ->
    it = @relatives[x]
    it.honoredas? or it.delivers? or it.promises?
  isHowObservation: (x) ->
    it = @relatives[x]
    it.whathonoredas? or it.whatdelivers?

  isGoodFor: (x) ->
    return 'unknown' unless it = @relatives[x.id||x]
    return 'yes' if it.whatdelivers? && it.whatdelivers > 0.5
    return 'no'  if it.whatdelivers? && it.whatdelivers < 0.5
    return 'unknown'

  pursualState: (x) ->
    sought = @isSought(x)
    handled = @isHandled(x)
    console.log 'pursualState', (x.id||x), sought, handled
    switch
      when sought then 'seeking'
      when handled then 'enjoying'
      else 'abandoned'

  isSought: (x) ->
    sought = @observations[x.id||x]?.sought
    t = new Timeframe(sought)
    console.log 'isSought', sought, t
    t.isActive()
  isHandled: (x) ->
    valued = @observations[x.id||x]?.valued
    return false if @isSought(x)
    t = new Timeframe(valued)
    console.log 'isHandled::valued', valued, t
    t.isActive()
  isAbandoned: (x) ->
    !(new Timeframe(@observations[x.id||x]?.valued).isActive())

  infixPhrase: (x) ->
    it = @relatives[x]
    switch
      when it.delivers? && it.delivers < 0.5
        return 'hasn\'t lead to'
      when @isAbandoned(x)
        return 'abandoned for'
      when it.delivers
        return 'led to'
      when it.promises
        return 'trying for'
  whyPrefix: (x) ->
    it = @relatives[x]
    switch
      when it.honoredas? then "it's part of"
      when it.delivers? then "it leads to"
  howSuffix: (x) ->
    it = @relatives[x]
    switch
      when it.whatdelivers? && it.whatdelivers > 0.5 then "leads to this"
      when it.whatpromises? then "promises this"
      when it.whathonoredas? then "is part of this"

  valence: (x) ->
    it = @relatives[x]
    switch
      when it.delivers? && it.delivers < 0.5
        return 'negative'
      when it.delivers
        return 'positive'
      else
        return 'neutral'

  remove: (x) ->
    rel = ['delivers', 'whatdelivers', 'promises', 'whatpromises', 'honoredas', 'whathonoredas'].filter((rel) => @relatives[x][rel])[0]
    console.log 'trying to remove', current_user_id, x, rel, @value
    Observations.unset(current_user_id, @value, rel, x)

  @suffixPhrase: (rel, val) ->
    switch rel
      when 'whatdelivers'   then 'delivered'

  @set: (guy, x, rel, y, val) ->
    inv = if rel.match(/^what/) then rel.replace('what', '') else "what#{rel}"
    @_set(guy, x, rel, y, val, true)
    @_set(guy, y, inv, x, val, true)

  @_set: (guy, x, rel, y, val, starting) ->
    @_set(guy, x, @up[rel], y, val, false) if @up[rel]
    @unset(guy, x, @down[rel], y) if @down[rel] and starting
    fb('claims/%/%/%/%', guy, x.id, rel, y.id).set val

  @unset: (guy, x, rel, y) ->
    inv = if rel.match(/^what/) then rel.replace('what', '') else "what#{rel}"
    fb('claims/%/%/%/%', guy, x.id||x, rel, y.id||y).remove()
    fb('claims/%/%/%/%', guy, y.id||y, inv, x.id||x).remove()
    @unset(guy, x, @down[rel], y) if @down[rel]

  @up: {
    delivers:       'promises',
    whatdelivers:   'whatpromises'
  }

  @down: {
    whatpromises:  'whatdelivers',
    promises:      'delivers',
  }
