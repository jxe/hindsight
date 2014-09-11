class window.ListsEditor extends Page
  initialize: (@value, @resource) ->
    resource = @resource
    @observe Someone.usingThis(), 'onListsFor', value: @value.id
  
  onListsFor: (lists) ->
    @find(".list").empty()
    @find("h3.header").hide()
    
    for list_type, entries of lists
      list_type = experiencesByBackLabel[list_type]
      @find("h3.header.#{list_type}").show()
      
      n = 0
      for value_id in entries
        v = Value.fromId(value_id)
        $v = $( v.asListEntry count: ++n, link: (if list_type == 'Experiment' then 'refile') )
        @find(".#{list_type}.list").append $v
  
  # note: add facebook to your "value" lists
  # segmented: useFor, priors, distractions
  # block button add facebook here
  # list
  
  @content: (value, resource) ->
    @div class: 'concern_view chilllozenges', =>
      @header class: 'bar bar-nav', =>
        @a class: 'icon icon-left-nav pull-left', click: 'back'
      @div class: 'content', =>
        @subview 'resourcePicker', new ReasonPicker hint: 'Add something...', style: 'margin: 5px', type: 'accomplishment'
        @div click: 'editReason', class: 'content-padded', =>
          @h4 class: 'prompt', =>
            @raw value.lozenge() 
            @raw '<br>'
            @text "the good, the bad, the ugly"
        
        for x in ['Experiment', 'LeadIn', 'WayOfDoing', 'Distraction']
          @h3 class: "#{x} header", =>
            @text window[x].pluralPrefix
            @raw ' '
            @raw value.lozenge() 
          @ul click: 'listClicked', list: x, class: "table-view list #{x} expando"
  
  onChoseValue: (r) =>
    new Experiment(r, @value).claimedBy(current_user_id)
   
  listClicked: (ev) =>
    return if $(ev.target).parents('.bubble').length
    list = $(ev.target).pattr('list')
    subvalue = $(ev.target).pattr('subvalue')
    if @bubble
      @bubble.remove()
      @bubble = null
      return
    if list and subvalue
      @bubble = new Bubble(this, list, Value.fromId(subvalue)).appendTo($(ev.target).parents('li'))
  
  editReason: ->
    @pushPage new ReasonEditor(@value)

    

class window.Bubble extends View
  initialize: (@parent, @list, @subvalue) ->
  @content: (parent, list, subvalue) ->
    @div class: 'bubble', =>
      @h4 'File this:'
      @ul =>
        for x in Wisdom.kindsOfBetween(subvalue, parent.value)
          if x != list
            @li =>
              @a switch: x, click: 'chose', =>
                if x == 'Experiment'
                  @b 'still figuring it out'
                else
                  @b window[x].preposition
                  @raw " " + parent.value.lozenge()
      @div style: 'text-align:right', =>
        @a class: 'recessed', click: 'remove', 'remove'

  remove: (ev) =>
    Wisdom.destroy(current_user_id, @subvalue, @parent.value)
    
  chose: (ev) =>
    list = $(ev.target).pattr('switch')
    new window[list](@subvalue, @parent.value).claimedBy(current_user_id)
