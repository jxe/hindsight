class window.Page extends View
  back: ->
    this.parents('.pager_viewport').view().pop()
    return false
  push: (el) ->
    this.parents('.pager_viewport').view().push(el)

class window.Modal extends View
  openIn: (@parent) =>
    parent.prepend(this)
    backdrop = $("<div class='hovermodalbackdrop'></a>").click => @close()
    parent.prepend(backdrop)
  close: =>
    @parent.find('.hovermodalbackdrop').remove()
    this.remove()
    @parent.didclosemodal(this) if @parent.didclosemodal

