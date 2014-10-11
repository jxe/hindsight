class window.Typeahead extends View
  @content: (options) ->
    @form class: options.class, style: options.style, =>
      @input outlet: 'input', placeholder: options.hint, type: 'search'
      @button type: 'submit', class: 'not_there'
  initialize: (options) =>
    { suggestions, onchoose, onadded, renderer, hint } = options
    @sub this, 'submit', (ev) =>
      ev.preventDefault()
      false
    @sub @input, 'typeahead:selected', (ev, data) =>
      console.log 'typeahead:selected'
      if data.adder
        onadded data.name
      else
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
