# class window.Choice extends Accomplishment
# class window.Activity extends Accomplishment

class window.Value
  @types: ->
    accomplishment: Accomplishment
    experience: Experience
    capacity: Capacity
    engagement: Engagement  # created from URLs only
  constructor: (@id, data) ->
    for k, v of data
      this[k] = v
  @fromId: (id, data = {}) =>  
    [ data.type, data.name ] = id.split(': ')
    klass = @types()[data.type]
    new klass id, data
  @create: (type, name) =>
    r = Value.fromId("#{type}: #{name}")
    r.kindOf(r.constructor.root)
    r
  @desc: (type) ->
    @types()[type].desc
  isRoot: ->
    @constructor.root == @id
  store: ->
    fb('values').child(@id).update
      type: @type
      name: @name
      url: @url
  
  # persistence and data model
  
  
  onValueChanged: (obj, sel) =>
    obj.watch fb('values').child(@id), 'value', sel, (snap) -> snap.val()
  
  kindOf: (v) ->
    fb('values/%/kindOf/%', @id, v.id || v).set(true)
    fb('values/%/kindOf/%', @id, v.constructor.root).remove()
    v
  addAlias: (text) ->
    fb('values/%/aliases/%', @id, text).set true
  hasKeyExperience: (v) ->
    fb('values/%/keyExperiences/%', @id, v.id).set true
  requiresCapacity: (v) ->
    fb('values/%/requiredCapacities/%', @id, v.id).set true
  mergeInto: (otherValue) =>
    fb('values/%', @id).once 'value', (snap) =>
      v = snap.val()
      v.aliases ||= {}
      v.aliases[@name] = true
      fb('values/%/aliases', otherValue.id).update(v.aliases)
      fb('values/%/keyExperiences', otherValue.id).update(v.keyExperiences)
      fb('values/%/requiredCapacities', otherValue.id).update(v.requiredCapacities)
      fb('values/%', @id).remove()  # todo, wait for the above to commit first!

  # reviewing
  
  experiencedAs: (what, options) ->
    fb('experience/%/%/%', options.by, @id, options.for.id).set "#{what}For"
    fb('experience/%/%/%', options.by, options.for.id, @id).set what
  
  # outcomesForUser: (uid, value, outcomes) ->
    
  # text and display!

  asListEntry: (notes) =>
    @lozenge(notes)
  
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
          


class window.Experience extends Value
  @desc: "<b>Feel</b><br>something you like to experience"
  @root: 'experience: good experience'

class window.Accomplishment extends Value
  hasKeyExperiences: true
  hasRequiredCapacities: true
  @desc: "<b>Do</b><br>A thing to do <i>daily</i> or <i>weekly</i>"
  @root: 'accomplishment: good thing to do'



class window.Capacity extends Experience
  canEnableAccomplishment: true
  @desc: "<b>Have</b><br>A capability you'd like to <i>have</i> available",
  @root: 'capacity: thing you can have'


class window.Engagement extends Accomplishment
  @fromResource: (r) ->
    Value.fromId("engagement: using #{r.firebase_path()}", url: r.canonUrl)