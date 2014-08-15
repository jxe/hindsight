class window.Reason
  @types: ['accomplishment', 'capacity', 'experience']
  constructor: (@id, @name) ->
    @type = @id.split(': ')[0]

  @classFromType: (type) ->
    switch type
      when 'capacity' then Capacity
      when 'experience' then Experience
      when 'accomplishment' then Accomplishment
      else Reason
  
  @fromId: (id) =>
    klass = @classFromType(id.split(': ')[0])
    new klass(id, id.split(': ')[1])
  @create: (type, name) =>
    r = Reason.fromId("#{type}: #{name}")
    r.kindOf(r.constructor.root)
    r
  isRoot: ->
    @constructor.root == @id
  
  couldRequireCapacities: false,
  couldHaveKeyExperiences: false,

  experienceOptions: {
    'key': {
      hopedFor: true
      triedFor: true
      leadTo: true
      usedFor: true
      abandonedFor: false
    },
    'helped': {
      hopedFor: true
      triedFor: true
      leadTo: false
      usedFor: true
      abandonedFor: false
    },
    'abandoned': {
      hopedFor: true
      triedFor: true
      leadTo: false
      usedFor: false
      abandonedFor: true
    },
    'trying': {
      hopedFor:true
      triedFor: true
      leadTo: false
      usedFor: false
      abandonedFor: false
    }
  }
  summarize: (outcomes) ->
    console.log 'summarizing: ', outcomes
    return 'abandoned' if outcomes.abandonedFor
    return 'key' if outcomes.leadTo
    return 'helped' if outcomes.usedFor
    return 'trying'
  labelFor: (outcomes) ->
    @experienceOptionLabels()[@summarize(outcomes)]
  headingFor: (outcomes) ->
    @experienceOptionHeadings()[@summarize(outcomes)]
    
  # events!
  
  onConcernState: (view, sel, uid, cb) ->
    view.watch fb('experience/%/values/%', uid, @id), 'value', sel, (snap) ->
      snap.val() || {}
  
  onReasonChanged: (obj, sel) =>
    obj.watch fb('values').child(@id), 'value', sel, (snap) -> snap.val()

    
  # setters!
  
  userIsSucceeding: (uid, bool) ->
    fb('experience/%/values/%/navigable', uid, @id).set(bool)
  kindOf: (v) ->
    fb('values/%/kindOf/%', @id, v.id || v).set(true)
    fb('values/%/kindOf/%', @id, v.constructor.root).remove()
  addAlias: (text) ->
    fb('values/%/aliases/%', @id, text).set true
  hasKeyExperience: (v) ->
    fb('values/%/keyExperiences/%', @id, v.id).set true
  requiresCapacity: (v) ->
    fb('values/%/requiredCapacities/%', @id, v.id).set true
  
  mergeInto: (otherReason) =>
    fb('values/%', @id).once 'value', (snap) =>
      v = snap.val()
      v.aliases ||= {}
      v.aliases[@name] = true
      fb('values/%/aliases', otherReason.id).update(v.aliases)
      fb('values/%/keyExperiences', otherReason.id).update(v.keyExperiences)
      fb('values/%/requiredCapacities', otherReason.id).update(v.requiredCapacities)
      fb('values/%', @id).remove()  # todo, wait for the above to commit first!
  
  store: ->
    fb('values').child(@id).update name: @name

  
    
  # text and display!
  
  @desc: (type) -> @classFromType(type).desc
  
  experienceOptionsForKnowsHow: (knowsHow) ->
#    console.log 'experienceOptionsForKnowsHow:', knowsHow
    if knowsHow
      return [ 'key', 'helped', 'trying', 'abandoned' ]
    else 
      return [ 'helped', 'trying', 'abandoned' ]
  
  experienceOptionLabels: ->
    {
      'trying':    @tryingLabel      || "trying for"
      'key':       @keyLabel         || "lead to"
      'helped':    @helpedLabel      || "helped with"
      'abandoned': @abandonedLabel   || "didn't lead to"
    }
  experienceOptionHeadings: ->
    {
      'trying':    @tryingHeading    || "is under review"
      'key':       @keyHeading       || "is key"
      'helped':    @helpedHeading    || "helps for this"
      'abandoned': @abadondedHeading || "sucks for this"
    }
  successQuestion: ->
    "I do <b>#{@lozenge()}</b> often"
  present_tense: ->
    @name.replace(/ing/, '')

  lozenge: (outcomes) =>
    outcomes ||= {}
    [ id, name ] = [ @id, @name ]
    if outcomes.abandonedFor
      color = 'poorly'
    else if outcomes.leadTo or outcomes.usedFor
      color = 'well'
    else
      color = 'pending'
    $$$ ->
      @span reason: id, class: "hindsight-lozenge #{color}", =>
        @span class: 'gem'
        @span class: 'text', =>
          @b name
          
          
          
class Capacity extends Reason
  @desc: "<b>Have</b><br>A capability you'd like to <i>have</i> available",
  @root: 'capacity: thing you can have'
  successQuestion: ->
    "I have the <b>#{@lozenge()}</b> I wanted"
#  deliveredHeading: "was key"
#  abandonedForHeading: "was a distraction"
  couldHaveKeyExperiences: true
  
class Accomplishment extends Reason
  @desc: "<b>Do</b><br>A thing to do <i>daily</i> or <i>weekly</i>"
  @root: 'accomplishment: good thing to do'
  successQuestion: ->
    "I know what's good for <b>#{@lozenge()}</b>"
#  deliveredHeading: "is key"
  couldHaveKeyExperiences: true
  couldRequireCapacities: true
  
class Experience extends Reason
  @desc: "<b>Feel</b><br>something you like to experience"
  @root: 'experience: good experience'
  successQuestion: ->
    "Some things help me <b>#{@present_tense()}</b>"
#  deliveredHeading: "is great"
