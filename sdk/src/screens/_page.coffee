class window.Page extends View
  back: ->
    this.parents('.pager_viewport').view().pop()
    return false
  push: (el) ->
    this.parents('.pager_viewport').view().push(el)
  @tabs: (tabnames, options, eachTab) ->
    options.class = 'segmented-control'
    options.selectedTab ||= tabnames[0]
    @div options, =>
      for tabname in tabnames
        selected = options.selectedTab == tabname
        @div tabname: tabname, class: "control-item #{if selected then 'active'}", click: 'setTab', tabname
    @div class: 'tab-contents',  =>
      for tabname in tabnames
        selected = options.selectedTab == tabname
        @div class: "#{tabname} tab-content #{options.tabClass}", style: (if !selected then "display:none"), ->
          eachTab(tabname)
  setTab: (ev) ->
    $(ev.target).addClassAmongSiblings('active')
    name = $(ev.target).attr('tabname')
    $(".tab-content.#{name}").showAmongSiblings()