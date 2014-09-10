values = (obj) ->
  return [] if !obj
  Object.keys(obj).map( (x) ->
    obj[x].id = x; return obj[x];
  )


class window.Typeahead extends View
  @content: (options) ->
    @form class: options.class, style: options.style, =>
      @input outlet: 'input', placeholder: options.hint, type: 'search'
      @button type: 'submit', class: 'not_there'
  initialize: (options) =>
    { suggestions, onchoose, onadded, renderer, hint } = options
    @sub this, 'submit', (ev) =>
      ev.preventDefault();
#      onadded(@input.val())
#      @input.typeahead('val', '')
      false
    @sub @input, 'typeahead:selected', (ev, data) =>
      console.log 'typeahead:selected'
      if data.adder
        console.log '(typeahead:onadded) this is: ', this
        onadded data.name
      else
        console.log '(typeahead:onchoose) this is: ', this
        onchoose data
      @input.typeahead('val', '')
    @input.typeahead({autoselect:true, minLength: 0},
      displayKey: 'name',
      source: (query, cb) =>
        cb(suggestions(query?.toLowerCase?()))
      templates:
        suggestion: renderer
    ,
      displayKey: 'name',
      source: (query, cb) =>
        cb([name: query, adder: true])
      templates:
        suggestion: renderer
    )
    @input.typeahead('val', '')



class window.Firecomplete extends Typeahead
  initialize: (params) ->
    @options = []
    @sub params.fb, 'value', (snap) =>
      @options = values(snap.val())
      @options = @options.filter(params.filter) if params.filter
    params.suggestions = (q) =>
      return @options unless q
      return @options.filter (x) ->
        return x.name&&x.name.toLowerCase().indexOf(q) >= 0
    super params
