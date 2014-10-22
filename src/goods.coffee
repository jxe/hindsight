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
    fb('gifts').child(@id).update
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
  couldInclude: (subvalue) ->
    @type == subvalue.type
  couldLeadTo: (parentValue) ->
    false
  
  # persistence and data model
    
  addAlias: (text) ->
    fb('gifts/%/aliases/%', @id, text).set true

  mergeInto: (otherValue) =>
    fb('gifts/%', @id).once 'value', (snap) =>
      v = snap.val()
      v.aliases ||= {}
      v.aliases[@name] = true
      fb('gifts/%/aliases', otherValue.id).update(v.aliases)
      fb('gifts/%', @id).remove()  # todo, wait for the above to commit first!

    
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
      @span reason: id, class: "hindsight-lozenge #{params.valence || 'neutral'}", =>
        @span class: 'gem'
        @span class: 'text', =>
          @b title

  lozengeTitle: ->
    @name


class window.Impression extends Good
  @root: 'impression: good feeling'
  @canOccur: true

class window.Recognition extends Good
  @root: 'recognition: being who and where I want to be'
  @rootOccuranceLabel: 'being who and where I want to be'
  @rootAssetLabel: 'personal or environmental alignment'
  @canOccur: true
  @canBeAcquired: true

class window.Activity extends Good
  @root: 'activity: doing what I value'
  @canOccur: true
  isActivity: true
  couldInclude: (subvalue) ->
    subvalue.type == 'equipment' or super(subvalue)
  couldLeadTo: (parentValue) ->
    not parentValue.isActivity

class window.Equipment extends Good
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
