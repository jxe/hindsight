
## quick extensions to the spacepen ##

View::[k] = v for own k, v of {
  sub: (ref, ev, fn) ->
    ref.on(ev, fn)
    (@offs ||= []).push -> ref.off(ev, fn)
    
  watch: (ref, ev, sel, transform) ->
    @subs ||= {}
    fn = (data) =>
      this[sel].call(this, transform(data))
    ref.on(ev, fn)
    @subs[sel] = -> ref.off(ev, fn)
    
  observe: (ref, subfn, args...) ->
    sel = subfn
    if subfn.match(/:/)
      [subfn, sel] = subfn.split(':')
    @subs[sel]() if @subs and @subs[sel]
    ref[subfn].call(ref, this, sel, args...) if ref

  beforeRemove: ->
    o() for o in @offs if @offs
    o() for sel, o of @subs if @subs
  pushPage: (v) ->
    @parents('.pager_viewport').view().push(v)
  popPage: ->
    @parents('.pager_viewport').view().pop()
}


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
