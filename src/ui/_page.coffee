class window.Page extends View
  back: ->
    this.parents('.pager_viewport').view().pop()
    return false
  push: (el) ->
    this.parents('.pager_viewport').view().push(el)
  menu: (key, prompt, menu) =>
    new MenuPopup(this, key, prompt, menu)

class window.Modal extends View
  openIn: (@parent) =>
    parent.prepend(this)
    backdrop = $("<div class='hovermodalbackdrop'></a>").click => @close()
    parent.prepend(backdrop)
  close: =>
    @parent.find('.hovermodalbackdrop').remove()
    this.remove()
    @parent.didclosemodal(this) if @parent.didclosemodal

class window.Menu extends View
  initialize: (options, @cb) ->
  @content: (options) ->
    @ul class: 'table-view card options', click: 'clicked', =>
      for x in options
        @li id: x[0], class: 'table-view-cell media', =>
          @a =>
            @span class: "media-object pull-left icon icon-#{x[2]}"
            @div class: 'media-body', =>
              @raw x[1]
  clicked: (ev) =>
    @cb($(ev.target).pattr('id'))


class window.MenuModal extends Modal
  initialize: =>
    options = @options()
    @find('.options').html $$ ->
      for x in options
        @li id: x[0], class: 'table-view-cell media', =>
          @a =>
            @span class: "media-object pull-left icon icon-#{x[2]}"
            @div class: 'media-body', =>
              @raw x[1]
  @content: ->
    @div class: 'hovermodal chilllozenges', =>
      @div class: 'content-padded', =>
        @h4 outlet: 'prompt', click: 'promptClicked'
      @ul class: 'table-view card options', click: 'clicked'
      @div outlet: 'footerView', click: "footerClicked"
  clicked: (ev) =>
    @cb($(ev.target).pattr('id'))


class window.MenuPopup extends Modal
  initialize: (@parent, @key, prompt, menu, extras) =>
    @openIn parent
  @content: (parent, key, prompt, menu, extras) ->
    extras ||= {}
    @div class: 'hovermodal', =>
      @div class: 'content-padded', =>
        @h4 click: 'promptClicked', =>
          @raw prompt
      @ul class: 'table-view card options', click: 'clicked', =>
        for k, info of menu
          @li id: k, class: 'table-view-cell media', =>
            @a =>
              @span class: "media-object pull-left icon icon-#{info.icon}" if info.icon
              @div class: 'media-body', =>
                @raw(info.text || info)
      @div outlet: 'footerView', click: "footerClicked", extras.footer if extras.footer
  clicked: (ev) =>
    @parent["#{@key}Clicked"].apply(@parent, [$(ev.target).pattr('id')])
    @close()


class window.WordChoice extends View
  initialize: (@startingWord, @options, @obj, @meth) ->
  @content: (startingWord, options, cb) ->
    @span class: 'WordChoice', =>
      @span class: 'word', click: 'toggle', startingWord || '...'
      @div class: 'choices segmented-control', =>
        for word in options
          @div word: word, class: "control-item #{if startingWord == word then 'active'}", click: 'setWord', word
  toggle: ->
    @toggleClass('open')
  setWord: (word) =>
    if word.target
      ev = word 
      word = $(ev.target).pattr('word')
    @find("[word='#{word}']").addClassAmongSiblings('active')
    @find('.word').html word
    @obj["#{@meth}Changed"].apply(@obj, [word]) if ev
    @removeClass 'open'
