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

class window.MenuModal extends Modal
  initialize: =>
    options = @options()
    @find('.options').html $$ ->
      for x in options
        @li id: x[0], click: 'clicked', class: 'table-view-cell media', =>
          @a =>
            @span class: "media-object pull-left icon icon-#{x[2]}"
            @div class: 'media-body', =>
              @raw x[1]
  @content: ->
    @div class: 'hovermodal chilllozenges', =>
      @div class: 'content-padded', =>
        @h4 outlet: 'prompt', click: 'promptClicked'
      @ul class: 'table-view card options'
      @div outlet: 'footerView', click: "footerClicked"
  clicked: (ev) =>
    @cb($(ev.target).pattr('id'))
