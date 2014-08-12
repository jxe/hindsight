class window.Reason
  constructor: (@id, @name) ->
    @type = @id.split(': ')[0]

  @classFromType: (type) ->
    switch type
      when 'asset' then Asset
      when 'feeling' then Feeling
      when 'activity' then Activity
      when 'character' then Character
      else Reason
  
  @fromId: (id) =>
    klass = @classFromType(id.split(': ')[0])
    new klass(id, id.split(': ')[1])
  
  isRoot: ->
    @constructor.root == @name
  

  
  # events!
  
  onConcernState: (view, uid, cb) ->
    view.sub fb('experience/%/reasons/%', uid, @id), 'value', (snap) ->
      v = snap.val()
      cb(v?.concerned_with, v?.doable)
  
  onOutcomesChanged: (obj, sel, uid) =>
    obj.watch fb('experience/%/resources', uid), 'value', sel, (snap) =>
      v = snap.val()
      result = {}
      for x, xd of v
        if outcome = xd.for?[@id]?.assessment
          result[outcome] ||= []
          result[outcome].push Resource.from_firebase_path(x)
      result
  
  onReasonChanged: (obj, sel) =>
    obj.watch fb('reasons').child(@id), 'value', sel, (snap) -> snap.val()

    
  # setters!
  
  userIsSucceeding: (uid, bool) ->
    fb('experience/%/reasons/%/doable', uid, @id).set(bool)
  setHypernym: (v) ->
    fb('reasons/%/kind_of', @id).set(v.id)
  addRequirement: (v) ->
    fb('reasons/%/requires/%', @id, v.id).set name: v.name
  addAlias: (text) ->
    fb('reasons/%/aliases/%', @id, text).set true
  
  mergeInto: (otherReason) =>
    fb('reasons/%', @id).once 'value', (snap) =>
      v = snap.val()
      v.aliases ||= {}
      v.aliases[@name] = true
      fb('reasons/%/aliases', otherReason.id).update(v.aliases)
      fb('reasons/%/requires', otherReason.id).update(v.requires)
      fb('reasons/%', @id).remove()  # todo, wait for the above to commit first!
  
  store: ->
    fb('reasons').child(@id).update name: @id

  
    
  # text and display!
  
  @types: ->
    return \
      activity: "<b>Activity or Lifestyle</b><br>A thing to do <i>daily</i> or <i>weekly</i>",
      feeling: "<b>Feeling or State of Mind</b><br>A change in how it feels to be me",
      asset: "<b>Asset</b><br>Something real you'd like to <i>have</i>",
      character: "<b>Character Trait</b><br>A <i>principle</i> about making choices differently"
  
  deliveredLabel: "lead to"
  helpedWithLabel: "helped with"
  helpedWithHeading: "helps"
  abandonedForLabel: "didn't lead to"
  abandonedForHeading: "sucks for this"
  tryingLabel: "trying for"
  tryingHeading: "might help"
  successQuestion: ->
    "I do <b>#{@name}</b> often"
  present_tense: ->
    @name.replace(/ing/, '')
  labelFor: (outcome) ->
    this["#{outcome}Label"]
  headingFor: (outcome) ->
    this["#{outcome}Heading"]

  requirementPrompt: (type) ->
    Reason.classFromType(type).requirementPrompt
  
  lozenge: (color) =>
    [ id, name ] = [ @id, @name ]
    color = 'well' if color == 'delivered' or color == 'helpedWith'
    color = 'poorly' if color == 'abandonedFor'
    $$$ ->
      @div reason: id, class: "hindsight-lozenge #{color}", =>
        @span class: 'gem'
        @span class: 'text', =>
          @b name


          
          
          
class Asset extends Reason
  @root: 'the good life'
  @requirementPrompt: 'requires assets'
  successQuestion: ->
    "I have the <b>#{@name}</b> I wanted"
  deliveredHeading: "was key"
  abandonedForHeading: "was a distraction"
  requirementTypes: ['activity']
  
class Activity extends Reason
  @root: 'good times'
  @requirementPrompt: 'means doing things'
  successQuestion: ->
    "I know what's good for <b>#{@present_tense()}</b>"
  deliveredLabel: 'key for'
  deliveredHeading: "is key"
  helpedWithHeading: "might help"
  abandonedForHeading: "doesn't help"
  tryingHeading: "don't know"
  requirementTypes: ['asset', 'character', 'feeling']

class Character extends Reason
  @root: 'being my best self'
  @requirementPrompt: 'requies acting in a certain manner'
  successQuestion: ->
    "I sometimes <b>#{@present_tense()}</b>"
  deliveredLabel: "was"
  deliveredHeading: "is great for this"
  helpedWithHeading: "can be good"
  abandonedForLabel: "wasn't"
  requirementTypes: []

class Feeling extends Reason
  @root: 'feeling good'
  @requirementPrompt: 'means feeling a certain way'
  successQuestion: ->
    "Some things help me <b>#{@present_tense()}</b>"
  deliveredHeading: "is great for this"
  requirementTypes: []
  