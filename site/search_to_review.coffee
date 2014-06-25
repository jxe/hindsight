class window.SearchToReview extends View
  @content: (fb_path) ->
    @form =>
      @subview 'typeahead-input', new Fireahead 'Search for apps or urls', fb_path, (obj) ->
        unless window.current_user_id
          batshit.please_login()
          return false
        url = obj.typed || obj.url
        return Review.open(obj) unless obj.typed
        Links.info url, (canonical_url, shortname, longname, img) ->
          obj =
            url: canonical_url
            name: shortname
            image: img
          fb('resources').child(Links.asFirebasePath(canonical_url)).set obj
          Review.open(obj)
