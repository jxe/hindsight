class Item extends View
  @content: (inputs) ->
    { item, engagement, tags, followup_info } = inputs
    @div class: 'item row', =>
      @img src: item.img
      @h1 item.name
      @subview 'annotation', new Annotation(inputs)



class Annotation extends View
  @content: (inputs) ->
    { item, engagement, tags, followup_info } = inputs
    @div class: 'annotation', =>
      @p =>
        @text "For others, "
        @b engagement.gerund
        @text " this was about..."
      @div =>
        @text "For you?"
