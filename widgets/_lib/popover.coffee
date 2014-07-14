class window.Popover extends View
  @show: (attach_element, args...) ->
    x = new this(args...)
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
