class window.Good
  constructor: (@id, data) ->
    this[k] = v for k, v of data
    @load()
  @fromId: (id, data = {}) =>  
    [ data.type, data.name ] = id.split(': ')
    klass = @types()[data.type]
    new klass id, data
  @create: (type, name) =>
    r = Good.fromId("#{type}: #{name}")
    # r.kindOf(r.constructor.root)
    r.store()
    r
  store: ->
    fb('terms').child(@id).update
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

  couldBeHonoredAs: (y) =>
    return true if @type == y.type or (@type.isActivity and y.isActivity)
    return true if @isActivity  and y.isRecognition
    return false

  couldDeliver: (y) ->
    return true if @isActivity    and !y.isRecognition
    return true if @isRecognition and  y.isEquipment
    return true if @isEquipment   and  y.isActivity
    return false

  couldDrive: (y) ->
    return true if y.couldDeliver(this)
    return true if @isImpression  && !y.isImpression
    return true if @isRecognition &&  y.isExternal
    return false

  honoredAsLabel: (y) ->
    return "is part of"       if @isActivity  and y.isRecognition
    return "is part of"       if @isActivity  and y.isActivity
    return "is one kind of"   if @isEquipment and y.isEquipment
    return "is part of"       if @type == y.type

  # persistence and data model
    
  addAlias: (text) ->
    fb('terms/%/aliases/%', @id, text).set true

  mergeInto: (otherValue) =>
    fb('terms/%', @id).once 'value', (snap) =>
      v = snap.val()
      v.aliases ||= {}
      v.aliases[@name] = true
      fb('terms/%/aliases', otherValue.id).update(v.aliases)
      fb('terms/%', @id).remove()  # todo, wait for the above to commit first!

    
  # text and display!

  asListEntry: (notes) =>
    notes ||= {}
    closeicon = ''
    if notes.closable
      closeicon = "<a class='icon icon-close btn btn-link gray'></a>"
    link = if notes.link
      "<span class='pull-right list-item-hint'>#{notes.link}</span>" 
    else 
      ''
    "<li subvalue='#{@id}' class='table-view-cell'>#{closeicon} #{notes.prefix||''} #{@lozenge(notes)} #{notes.suffix||''}#{link}</li>"
  
  lozenge: (params) =>
    params ||= {}
    params = { valence: params } if params.length
    id = @id
    title = @lozengeTitle()
    $$$ ->
      @span reason: id, class: "-hsloz #{params.valence || 'neutral'}", =>
        @span ''
        @b title

  lozengeTitle: ->
    @name


class window.Impression extends Good
  isImpression: true
  @root: 'impression: good feeling'
  @canOccur: true

class window.Recognition extends Good
  isRecognition: true
  isAcquirable: true
  @root: 'recognition: being who and where I want to be'
  @rootOccuranceLabel: 'being who and where I want to be'
  @rootAssetLabel: 'personal or environmental alignment'
  @canOccur: true
  @canBeAcquired: true

class window.Activity extends Good
  isActivity: true
  isExternal: true
  @root: 'activity: doing what I value'
  @canOccur: true

class window.Equipment extends Good
  isEquipment: true
  isAcquirable: true
  isExternal: true
  @root: 'equipment: thing that supports me'
  @canBeAcquired: true

class window.Engagement extends Activity
  @fromResource: (r) ->
    Good.fromId("engagement: using #{r.firebase_path()}", url: r.canonUrl)
  load: ->
    [ @verb, @fbpath ] = @name.split ' '
    @resource = Resource.fromFirebasePath(@fbpath)
  lozengeTitle: ->
    "#{@verb} #{@resource.name()}"
