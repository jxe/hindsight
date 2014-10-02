# class window.Choice extends Accomplishment
# class window.Activity extends Accomplishment

class window.Value

  constructor: (@id, data) ->
    for k, v of data
      this[k] = v
    @load()
  @fromId: (id, data = {}) =>  
    [ data.type, data.name ] = id.split(': ')
    klass = @types()[data.type]
    new klass id, data
  @create: (type, name) =>
    r = Value.fromId("#{type}: #{name}")
    r.kindOf(r.constructor.root)
    r.store()
    r
  store: ->
    fb('values').child(@id).update
      type: @type
      name: @name
      url: @url || null
  
  @types: ->
    impression: Impression
    activity: Activity
    recognition: Recognition
    equipment: Equipment
    engagement: Engagement  # created from URLs only

  load: ->
  isRoot: ->
    @constructor.root == @id


  # persistence and data model
  
  onValueChanged: (obj, sel) =>
    obj.watch fb('values').child(@id), 'value', sel, (snap) -> snap.val()
  
  kindOf: (v) ->
    fb('values/%/kindOf/%', @id, v.id || v).set(true)
    fb('values/%/kindOf/%', @id, v.constructor.root).remove()
    v
  addAlias: (text) ->
    fb('values/%/aliases/%', @id, text).set true

  mergeInto: (otherValue) =>
    fb('values/%', @id).once 'value', (snap) =>
      v = snap.val()
      v.aliases ||= {}
      v.aliases[@name] = true
      fb('values/%/aliases', otherValue.id).update(v.aliases)
      fb('values/%/keyExperiences', otherValue.id).update(v.keyExperiences)
      fb('values/%/requiredAssets', otherValue.id).update(v.requiredAssets)
      fb('values/%', @id).remove()  # todo, wait for the above to commit first!

    
  # text and display!

  asListEntry: (notes) =>
    count = link = ''
    count = "#{notes.count}. " if notes.count
    link = "<span class='pull-right list-item-hint'>#{notes.link}</span>" if notes.link
    "<li subvalue='#{@id}' class='table-view-cell'>#{count} #{@lozenge(notes)} #{link}</li>"
  
  lozenge: (outcomes) =>
    outcomes ||= {}
    id = @id
    title = @lozengeTitle()
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
          @b title

  lozengeTitle: ->
    @name


# claims:
# - canDefine     -- defines
# - canBeDefined  -- whatdefines
# - canBeAcquiredOrRequired -- whatrequires
# - canRequire -- requires

# changes to followups
# - canGenerate


class window.Impression extends Value
  @root: 'impression: good feeling'
  @canOccur: true
  @canDefine: true

class window.Recognition extends Value
  @root: 'recognition: being who and where I want to be'
  @rootOccuranceLabel: 'being who and where I want to be'
  @rootAssetLabel: 'personal or environmental alignment'
  @canOccur: true
  @canBeAcquiredOrRequired: true

class window.Activity extends Value
  @root: 'activity: doing what I value'
  @canOccur: true
  @canBeDefined: true
  @canGenerate: true
  @canRequire: true

class window.Equipment extends Value
  @root: 'equipment: thing that supports me'
  @canBeAcquiredOrRequired: true


class window.Engagement extends Activity
  @fromResource: (r) ->
    Value.fromId("engagement: using #{r.firebase_path()}", url: r.canonUrl)
  load: ->
    [ @verb, @fbpath ] = @name.split ' '
    @resource = Resource.fromFirebasePath(@fbpath)
  lozengeTitle: ->
    "#{@verb} #{@resource.name()}"
