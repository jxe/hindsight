values= (obj) ->
  return [] if !obj
  Object.keys(obj).map( (x) ->
    obj[x].id = x; return obj[x];
  )

class window.Fireahead extends View
  @content: (hint, fbref, cb) ->
    @form =>
      @input outlet: 'input', placeholder: hint, type: 'search', class: 'fireahead'
      @button type: 'submit', class: 'not_there'
  initialize: (hint, fbref, cb, add_choices) =>
    @options = []
    @sub fbref, 'value', (snap) ->
      @options = values(snap.val());
    @sub this, 'submit', (ev) =>
      ev.preventDefault();
      cb typed: @input.val()
      @input.typeahead('val', '')
      false
    @sub @input, 'typeahead:selected', (ev, data) =>
      cb(data)
      @input.typeahead('val', '')
    @input.typeahead({autoselect:true},
      displayKey: 'name',
      source: (query, cb) =>
        q = query?.toLowerCase?()
        return cb(@options) unless q
        choices = options.filter (x) ->
          return x.name&&x.name.toLowerCase().indexOf(q) >= 0
        return cb(add_choices(query)) if add_choices and not choices.length
        return cb(choices)
    )
    @input.typeahead('val', '')
