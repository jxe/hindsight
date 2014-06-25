class window.Modal extends View
  @show: (args...) ->
    x = new this(args...)
    x.appendTo 'body'
    setTimeout((-> x.toggleClass 'active'), 0)
  close: ->
    this.toggleClass('active')
    setTimeout((=> this.remove()), 1000)
