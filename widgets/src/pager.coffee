class window.Pager extends View
  @content: (root_element) ->
    @div class: 'pager_viewport'
  initialize: (root_element) ->
    this.append(root_element)
    @adjust_viewport()

  adjust_viewport: ->
    console.log('adjusting viewport')
    el = this.children().last()
    rect = el[0].getBoundingClientRect()
    console.log('setting css', '-webkit-transform', "translateX(-#{rect.left}px)")
    this.css('-webkit-transform', "translateX(-#{rect.left}px)")
    
  push: (el) ->
    this.append(el)
    @adjust_viewport()
    # slide left of viewport over

  pop: ->
    this.children().last().remove()
    @adjust_viewport()
    # slide left of viewport to second to top
    # and remove the top