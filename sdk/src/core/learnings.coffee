class window.Learnings
  @types: ['satisfies', 'leadsto', 'trumps', 'evaluatingfor']
  @set: (guy, x, rel, y, val) ->
    fb('learnings/%/%/%/%', guy, x.id, rel, y.id).set val
    fb('learnings/%/%/%/%', guy, y.id, @inverse(rel), x.id).set val
    for relationToRemove in @incompatible(rel)
      @unset(guy, x, relationToRemove, y)
    if rel == 'evaluatingfor'
      fb('common/hopes/%/%/%', x.id, y.id, guy).set true
  @unset: (guy, x, rel, y) ->
    fb('learnings/%/%/%/%', guy, x.id, rel, y.id).remove()
    fb('learnings/%/%/%/%', guy, y.id, @inverse(rel), x.id).remove()
  @inverse: (rel) ->
    if rel.match(/^what/) then rel.replace('what', '') else "what#{rel}"
  @incompatible: (rel) ->
    switch rel
      when 'satisfies'
        [ 'leadsto', 'trumps', 'whatsatisfies', 'evaluatingfor' ]
      when 'leadsto'
        [ 'satisfies', 'whatleadsto', 'evaluatingfor' ]
      when 'trumps'
        [ 'satisfies', 'whattrumps', 'evaluatingfor' ]
      when 'evaluatingfor'
        [  'satisfies', 'leadsto', 'trumps']
  @infixPhrase: (rel, val) ->
    return 'sucks for' if val < 0.5
    switch rel
      when 'leadsto'       then 'led to'
      when 'satisfies'     then 'always good for'
      when 'evaluatingfor' then 'trying for'
  @suffixPhrase: (rel, val) ->
    switch rel
      when 'whatleadsto'   then 'delivered'
      when 'whatsatisfies' then 'is always good'



# class window.Experiment extends Wisdom
#   @pluralPrefix: 'evaluating for'

# class window.WayOfDoing extends Wisdom
#   @pluralPrefix: 'ways of'

# class window.LeadIn extends Wisdom
#   @pluralPrefix: 'leads to'
