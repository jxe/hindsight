class window.Wisdom
  constructor: (@subject, @object) ->
  claimedBy: (guy) ->
    fb('wisdom/%/%/%/%', guy, @subject.id, @constructor.forwardLabel, @object.id).set true
    fb('wisdom/%/%/%/%', guy, @object.id, @constructor.backLabel, @subject.id).set true
    @incompatibleExperiences().map (x) -> x.repudiatedBy(guy)
    if @constructor.name == 'Experiment'
      fb('common/hopes/%/%/%', @subject.id, @object.id, guy).set true
  repudiatedBy: (guy) ->
    fb('wisdom/%/%/%/%', guy, @subject.id, @constructor.forwardLabel, @object.id).remove()
    fb('wisdom/%/%/%/%', guy, @object.id, @constructor.backLabel, @subject.id).remove()
  @destroy: (guy, subject, object) ->
    [ 'WayOfDoing', 'LeadIn', 'Distraction', 'Experiment' ].map (x) =>
      kls = window[x]
      fb('wisdom/%/%/%/%', guy, subject.id, kls.forwardLabel, object.id).remove()
      fb('wisdom/%/%/%/%', guy, object.id, kls.backLabel, subject.id).remove()
  incompatibleExperiences: ->
    @constructor.not.map (x) =>
      new window[x](@subject, @object)
  @kindsOfBetween: (subject, object) ->
    if object.type == 'accomplishment'
      [ 'WayOfDoing', 'LeadIn', 'Distraction', 'Experiment' ]
    else
      [ 'LeadIn', 'Distraction', 'Experiment' ]

class window.Distraction extends Wisdom
  @desc: 'distractions'
  @preposition: 'is best to avoid for'
  @pluralPrefix: 'best avoided for'
  @forwardLabel: 'isDistractionFor'
  @backLabel: 'hasDistractions'
  @not: [ 'WayOfDoing', 'LeadIn', 'BetterThan', 'Experiment' ]

class window.Experiment extends Wisdom
  @desc: 'things you\'re experimenting with for this'
  @preposition: 'still figuring it out'
  @pluralPrefix: 'evaluating for'
  @forwardLabel: 'isExperimentFor'
  @backLabel: 'hasExperiments'
  @not: [ 'WayOfDoing', 'LeadIn', 'BetterThan', 'Distraction' ]

class window.WayOfDoing extends Wisdom
  @desc: 'ways of doing this'
  @preposition: 'as a way of'
  @pluralPrefix: 'ways of'
  @forwardLabel: 'isWayOfDoing'
  @backLabel: 'hasWaysOfDoing'
  @not: [ 'Distraction', 'Experiment', 'LeadIn' ]

class window.LeadIn extends Wisdom
  @desc: 'things that lead to this'
  @preposition: 'has lead to'
  @pluralPrefix: 'leads to'
  @forwardLabel: 'isLeadInFor'
  @backLabel: 'hasLeadIns'
  @not: [ 'Distraction', 'Experiment', 'WayOfDoing' ]

class window.BetterThan extends Wisdom
  @desc: 'better than this'
  @preposition: 'better than'
  @forwardLabel: 'isBetterThan'
  @backLabel: 'hasBetterThans'
  @not: [ 'Distraction', 'Experiment' ]

window.experiencesByBackLabel =
  hasWaysOfDoing: 'WayOfDoing'
  hasBetterThans: 'BetterThan'
  hasLeadIns: 'LeadIn'
  hasExperiments: 'Experiment'
  hasDistractions: 'Distraction'

window.experiencesByForwardLabel =
  isWayOfDoing: 'WayOfDoing'
  isBetterThanFor: 'BetterThan'
  isLeadIn: 'LeadIn'
  isExperimentFor: 'Experiment'
  isDistractionFor: 'Distraction'
