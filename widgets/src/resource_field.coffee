class window.ResourceField extends View
  @content: (hint, fb_path, onclick) ->
    hint ||= 'Search for apps or urls'
    @form class: 'expando', =>
      @subview 'typeahead-input', new Fireahead hint, fb_path, (obj, rf) ->
        if obj.typed
          Resource.fromUrl obj.typed, (r) ->
            onclick(r, rf)
        else
          onclick(Resource.fromFirebaseObject(obj), rf)
