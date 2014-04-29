values= (obj) ->
  return [] if !obj
  Object.keys(obj).map( (x) ->
    obj[x].id = x; return obj[x];
  )

class window.Fireahead extends View
  @content: (hint, fbref, cb) ->
    @form =>
      @input outlet: 'input'
      @button type: 'submit'
  initialize: (hint, fbref, cb) =>
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
      source: (query, cb) ->
        q = query && query.toLowerCase()
        cb(options.filter((x) ->
          return !query || (x.name&&x.name.toLowerCase().indexOf(q) >= 0)
        ))
    )
    @input.typeahead('val', '')
