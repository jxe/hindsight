class window.Good

  constructor: (@id, data) ->
    for k, v of data
      this[k] = v
    @load()
  @fromId: (id, data = {}) =>  
    [ data.type, data.name ] = id.split(': ')
    klass = @types()[data.type]
    new klass id, data
  @create: (type, name) =>
    r = Good.fromId("#{type}: #{name}")
    r.kindOf(r.constructor.root)
    r.store()
    r
  store: ->
    fb('goods').child(@id).update
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
    
  kindOf: (v) ->
    fb('goods/%/kindOf/%', @id, v.id || v).set(true)
    fb('goods/%/kindOf/%', @id, v.constructor.root).remove()
    v
  addAlias: (text) ->
    fb('goods/%/aliases/%', @id, text).set true

  mergeInto: (otherValue) =>
    fb('goods/%', @id).once 'value', (snap) =>
      v = snap.val()
      v.aliases ||= {}
      v.aliases[@name] = true
      fb('goods/%/aliases', otherValue.id).update(v.aliases)
      # fb('goods/%/keyExperiences', otherValue.id).update(v.keyExperiences)
      # fb('goods/%/requiredAssets', otherValue.id).update(v.requiredAssets)
      fb('goods/%', @id).remove()  # todo, wait for the above to commit first!

    
  # text and display!

  asListEntry: (notes) =>
    count = link = ''
    count = "#{notes.count}. " if notes.count
    link = "<span class='pull-right list-item-hint'>#{notes.link}</span>" if notes.link
    "<li subvalue='#{@id}' class='table-view-cell'>#{count} #{@lozenge(notes)} #{link}</li>"
  
  lozenge: (params) =>
    params ||= {}
    params = { valence: params } if params.length
    id = @id
    title = @lozengeTitle()
    $$$ ->
      @span reason: id, class: "hindsight-lozenge #{params.valence || 'neutral'}", =>
        @span class: 'gem'
        @span class: 'text', =>
          @b title

  lozengeTitle: ->
    @name

# changes to followups
# - canGenerate


class window.Impression extends Good
  @root: 'impression: good feeling'
  @canOccur: true
  @canDefine: true

class window.Recognition extends Good
  @root: 'recognition: being who and where I want to be'
  @rootOccuranceLabel: 'being who and where I want to be'
  @rootAssetLabel: 'personal or environmental alignment'
  @canOccur: true
  @canBeAcquiredOrRequired: true

class window.Activity extends Good
  @root: 'activity: doing what I value'
  @canOccur: true
  @canBeDefined: true
  @canGenerate: true
  @canRequire: true

class window.Equipment extends Good
  @root: 'equipment: thing that supports me'
  @canBeAcquiredOrRequired: true


class window.Engagement extends Activity
  @fromResource: (r) ->
    Good.fromId("engagement: using #{r.firebase_path()}", url: r.canonUrl)
  load: ->
    [ @verb, @fbpath ] = @name.split ' '
    @resource = Resource.fromFirebasePath(@fbpath)
  lozengeTitle: ->
    "#{@verb} #{@resource.name()}"
