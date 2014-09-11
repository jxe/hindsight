# class window.Choice extends Accomplishment
# class window.Activity extends Accomplishment

class window.Value
  @types: ->
    accomplishment: Accomplishment
    experience: Experience
    asset: Asset
    engagement: Engagement  # created from URLs only
  @descs: ->
    accomplishment: Accomplishment.desc
    experience: Experience.desc
    asset: Asset.desc
  constructor: (@id, data) ->
    for k, v of data
      this[k] = v
    @load()
  load: ->
  @fromId: (id, data = {}) =>  
    [ data.type, data.name ] = id.split(': ')
    klass = @types()[data.type]
    new klass id, data
  @create: (type, name) =>
    r = Value.fromId("#{type}: #{name}")
    r.kindOf(r.constructor.root)
    r.store()
    r
  @desc: (type) ->
    @types()[type].desc
  isRoot: ->
    @constructor.root == @id
  resultLabel: (x) ->
    switch experiencesByForwardLabel[x]
      when 'Experiment' then 'trying for'
      when 'WayOfDoing' then 'good for'
      when 'LeadIn' then 'lead to'
      when 'Distraction'
        if @type == 'accomplishment' then "wasn't good for"
        else "didn't lead to"
      else
        "#{x} #{experiencesByForwardLabel[x]}"
  favoriteLabel: (x) ->
    switch experiencesByBackLabel[x]
      when 'WayOfDoing' then 'try'
      when 'LeadIn' then 'start by'

  store: ->
    fb('values').child(@id).update
      type: @type
      name: @name
      url: @url || null
  
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
  requiresAsset: (v) ->
    fb('values/%/requiredAssets/%', @id, v.id).set true
  mergeInto: (otherValue) =>
    fb('values/%', @id).once 'value', (snap) =>
      v = snap.val()
      v.aliases ||= {}
      v.aliases[@name] = true
      fb('values/%/aliases', otherValue.id).update(v.aliases)
      fb('values/%/keyExperiences', otherValue.id).update(v.keyExperiences)
      fb('values/%/requiredAssets', otherValue.id).update(v.requiredAssets)
      fb('values/%', @id).remove()  # todo, wait for the above to commit first!

  # outcomesForUser: (uid, value, outcomes) ->
    
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


class window.Experience extends Value
  @desc: "<b>Feel</b><br>something you like to experience"
  @root: 'experience: good experience'

class window.Accomplishment extends Value
  hasKeyExperiences: true
  hasRequiredAssets: true
  @desc: "<b>Do</b><br>A goal, a lifestyle component, or a code of ethics"
  @root: 'accomplishment: good thing to do'



class window.Asset extends Experience
  canEnableAccomplishment: true
  @desc: "<b>Have</b><br>An aspect of yourself or environment that would give you new capabilities",
  @root: 'asset: thing you can have'


class window.Engagement extends Accomplishment
  @fromResource: (r) ->
    Value.fromId("engagement: using #{r.firebase_path()}", url: r.canonUrl)
  load: ->
    [ @verb, @fbpath ] = @name.split ' '
    @resource = Resource.fromFirebasePath(@fbpath)
  lozengeTitle: ->
    "#{@verb} #{@resource.name()}"
