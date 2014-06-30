class window.Popover extends View
  @show: (args...) ->
    x = new this(args...)
    x.appendTo 'body'
    setTimeout((->
      x.toggleClass 'visible'
      x.css display: "block", top: "110px"
      x.show_backdrop()
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
