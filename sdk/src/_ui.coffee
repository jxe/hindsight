
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



class window.Popover extends View
  @content: (attach_element) ->
    @div class: 'popover'
  @show: (attach_element, el) ->
    x = new this()
    $('.popover, .backdrop').remove();
    x.appendTo 'body'
    setTimeout((->
      x.toggleClass 'visible'
      
      rect = attach_element[0].getBoundingClientRect()

      # position vertically
      x.css display: "block", top: rect.bottom + 20
      
      # position horizontally
      x.css left: "150px"
      
      # position nose
      ## not sure how to address :before in js

      x.show_backdrop()
      x.append(el)
    ), 0)
  show_backdrop: ->
    @back = document.createElement('div')
    @back.classList.add('backdrop')
    $(@back).on 'touchend click', =>
      @close()
    this.parent().append(@back)
  close: ->
    this.toggleClass('visible')
    setTimeout((=> this.remove()), 1000)
    @back.parentNode.removeChild(@back)

    
class window.Pager extends View
  @content: (root_element) ->
    @div class: 'pager_viewport'
  initialize: (root_element) ->
    this.append(root_element)
    @adjust_viewport()

  adjust_viewport: (el) ->
    console.log('adjusting viewport')
    el = this.children().last() unless el
    left = el[0].offsetLeft
    console.log('setting css', '-webkit-transform', "translateX(-#{left}px)")
    this.css('-webkit-transform', "translateX(-#{left}px)")
    
  push: (el) ->
    this.append(el)
    @adjust_viewport(el)
    return this
    # slide left of viewport over
  pop: ->
    this.children().last().remove()
    @adjust_viewport()
    return this
    # slide left of viewport to second to top
    # and remove the top

class window.Page extends View
  back: ->
    this.parents('.pager_viewport').view().pop()
    return false
  push: (el) ->
    this.parents('.pager_viewport').view().push(el)

class window.Modal extends View
  @show: (args...) ->
    x = new this(args...)
    x.appendTo 'body'
    setTimeout((-> x.toggleClass 'active'), 0)
  close: ->
    this.toggleClass('active')
    setTimeout((=> this.remove()), 1000)
values= (obj) ->
  return [] if !obj
  Object.keys(obj).map( (x) ->
    obj[x].id = x; return obj[x];
  )


class window.Typeahead extends View
  @content: (options) ->
    @form =>
      @input outlet: 'input', placeholder: options.hint, type: 'search'
      @button type: 'submit', class: 'not_there'
  initialize: (options) =>
    { suggestions, onchoose, onadded, renderer, hint } = options
    @sub this, 'submit', (ev) =>
      ev.preventDefault();
#      onadded(@input.val())
#      @input.typeahead('val', '')
      false
    @sub @input, 'typeahead:selected', (ev, data) =>
      console.log 'typeahead:selected'
      if data.adder
        console.log 'onadded'
        onadded data.name, this
      else
        console.log 'onchoose'
        onchoose data, this
      @input.typeahead('val', '')
    @input.typeahead({autoselect:true, minLength: 0},
      displayKey: 'name',
      source: (query, cb) =>
        cb(suggestions(query?.toLowerCase?()))
      templates:
        suggestion: renderer
    ,
      displayKey: 'name',
      source: (query, cb) =>
        cb([name: query, adder: true])
      templates:
        suggestion: renderer
    )
    @input.typeahead('val', '')



class window.Firecomplete extends Typeahead
  initialize: (params) ->
    @options = []
    @sub params.fb, 'value', (snap) =>
      @options = values(snap.val())
      @options = @options.filter(params.filter) if params.filter
    params.suggestions = (q) =>
      return @options unless q
      return @options.filter (x) ->
        return x.name&&x.name.toLowerCase().indexOf(q) >= 0
    super params
