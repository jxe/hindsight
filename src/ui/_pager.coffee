class window.Pager extends View
  @content: (root_element) ->
    @div class: 'pager_viewport'
  initialize: (root_element) ->
    this.append(root_element)
    @adjust_viewport()

  adjust_viewport: (el) ->
    el = this.children().last() unless el
    left = el[0].offsetLeft
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
