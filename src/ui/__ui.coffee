class window.Stream
  constructor: (cb) ->
    @listeners ||= []
    cb(this)
  listen: (ev, ref, process) =>
    @listeners.push [ref, ev, process]
    ref.on ev, process if @obj and @meth
  emit: (x) => @obj[@meth].apply(@obj, [x])
  bind: (obj, meth) =>
    throw 'Bind called with nonobject' unless obj
    throw { message: 'Bind object has no such method', obj: obj, meth: meth } unless obj[meth]
    was_unbound = !@obj or !@meth
    obj.streams[meth].close() if obj.streams[meth]
    obj.streams[meth] = this
    [@obj, @meth] = [obj, meth]
    e[0].on e[1], e[2] for e in @listeners if was_unbound
  close: =>
    e[0].off e[1], e[2] for e in @listeners
    @listeners = @obj = @meth = null


window.pojo = (o) ->
  typeof o == 'object' and o.constructor == Object


## quick extensions to the spacepen ##

View::[k] = v for own k, v of {
  bind: (params) ->
    @streams ||= {}
    stream.bind(this, meth) for meth, stream of params
  sub: (ref, ev, fn) ->
    ref.on(ev, fn)
    (@offs ||= []).push -> ref.off(ev, fn)    
  beforeRemove: ->
    s.close() for name, s of @streams if @streams
    o() for o in @offs if @offs
  pushPage: (v) ->
    @parents('.pager_viewport').view().push(v)
  popPage: ->
    @parents('.pager_viewport').view().pop()
  setTab: (ev) ->
    $(ev.target).addClassAmongSiblings('active')
    name = $(ev.target).attr('tabname')
    className = name.replace(' ', '_')
    @find(".tab-content.#{className}").showAmongSiblings()
  setSegment: (ev) ->
    $(ev.target).addClassAmongSiblings('active')
    kind = $(ev.target).attr('segmentKind')
    name = $(ev.target).attr('tabname')
    this[kind + "Changed"](name)
}

View.segment = (kind, tabnames, selectedTab) ->
  @div class: 'segmented-control', =>
    for tabname, tabtext of tabnames
      selectedTab ||= tabname
      selected = selectedTab == tabname
      @div segmentKind: kind, tabname: tabname, class: "control-item #{if selected then 'active'}", click: 'setSegment', tabtext

View.tabs = (tabnames, options, eachTab) ->
  options.class = 'segmented-control'
  options.selectedTab ||= tabnames[0]
  @div options, =>
    for tabname in tabnames
      selected = options.selectedTab == tabname
      @div tabname: tabname, class: "control-item #{if selected then 'active'}", click: 'setTab', tabname
  @div class: 'tab-contents',  =>
    for tabname in tabnames
      selected = options.selectedTab == tabname
      className = tabname.replace(' ', '_')
      @div class: "#{className} tab-content #{options.tabClass}", style: (if !selected then "display:none"), ->
        eachTab(tabname)

## quick extension to the jquery

$.fn.pattr = (name) ->
  this.attr(name) || this.parents("[#{name}]").attr(name)

$.fn.addClassAmongSiblings = (name) ->
  this.siblings().removeClass(name)
  this.addClass(name)

$.fn.showAmongSiblings = (name) ->
  this.siblings().hide()
  this.show()

String::titleCase = ->
  this[0].toUpperCase() + this.slice(1)

