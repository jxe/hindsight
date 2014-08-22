class window.ListsEditor extends Page
  initialize: (@value, @resource) ->
    resource = @resource
    @observe Someone.usingThis(), 'onListsFor', value: @value.id
  
  onListsFor: (lists) ->
    console.log 'lists: ', lists
    # list -> resource(t/f)
    for list_type, entries of lists
      $(".#{list_type}").empty()
      for value_id in entries
        $(".#{list_type}").append Value.fromId(value_id).asListEntry(true)
  
  # note: add facebook to your "value" lists
  # segmented: useFor, priors, distractions
  # block button add facebook here
  # list
  
  @content: (value, resource) ->
    @div class: 'concern_view', =>
      @header class: 'bar bar-nav', =>
        @a class: 'icon icon-left-nav pull-left', click: 'back'
      @div class: 'content', =>
        if resource
          @div class: 'content-padded', =>
            @h4 class: 'prompt', "Add #{resource.name()} to your #{value.name} lists!"
        @tabs ['method', 'prior', 'distraction'], outlet: 'lists', (section) =>
          if resource
            @button list: section, class: 'btn btn-block', click: 'addResourceToList', "Add #{resource.name()}"
          @ul class: "table-view list #{section}"
        @subview 'resourcePicker', new ResourcePicker hint: 'What\'s good for this?'
  
  @tabs: (tabnames, options, eachTab) ->
    options.class = 'segmented-control'
    @div options, =>
      for tabname in tabnames
        @div tabname: tabname, class: 'control-item', click: 'setTab', tabname
    @div class: 'tab-contents', =>
      for tabname in tabnames
        @div class: "#{tabname} tab-content", ->
          eachTab(tabname)
  setTab: (ev) ->
    $(ev.target).addClassAmongSiblings('active')
    name = $(ev.target).attr('tabname')
    $(".tab-content.#{name}").showAmongSiblings()
    
  addResourceToList: (ev) =>
    list = $(ev.target).pattr('list')
    Engagement.fromResource(@resource).experiencedAs(list, for: @value, by: current_user_id)
  
  editReason: ->
    @pushPage new ReasonEditor(@value)
  