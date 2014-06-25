class window.Popover extends View
  @show: (args...) ->
    x = new this(args...)
    x.appendTo 'body'
    setTimeout((->
      x.toggleClass 'visible'
      x.css display: "block", top: "110px"
    ), 0)
  close: ->
    this.toggleClass('visible')
    setTimeout((=> this.remove()), 1000)
