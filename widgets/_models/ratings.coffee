window.Ratings =
  # FIXME: mocked :)
  situate: (current_resource_for_desire, best_options) ->
    return 'mixed'
  label: (type) ->
    switch type
      when 'mixed'
        return 'mixed reviews'
      when 'poorly'
        return 'going poorly'
      when 'well'
        return 'going well'
      else
        return type
