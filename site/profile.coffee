# todo replace with react-coffee

sections =
  app: 'Apps'
  city: 'Cities'
  website: 'Websites'
  product: 'Products'


class window.Profile extends View
  @load_into: (domid, uid) ->
    fb('people/%', uid)
      .plus fb('desires/%', uid)
      .plus fb('outcomes/%', uid)
      .plus fb('engagements/%', uid), (v, q) ->
        for url, engagement of v
          q.plus fb('resources/%', url)
      .on_full_value (v) ->
        v = v[Object.keys(v)[0]]
        $(domid).html(new Profile(v.people[uid], v.resources || {}, v.engagements[uid] || {}, v.desires[uid] || {}, v.outcomes[uid] || {}))

  @content: (person, resources, engagements, desires, outcomes) ->
    @div class:'profile', =>
      @header =>
        @img src: person.photo
        @h2 person.name
      @h3 'Goals'
      @ul =>
        for desire, info of desires
          @li =>
            @b desire
            @p "still_desired: #{info.still_desired}"
      @h3 "Reviews"
      @subview 'search', new SearchToReview(fb('resources'), 'Add apps or URLs')
      for type, label of sections
        contents = Object.keys(resources).filter((url) -> resources[url]?.type == type)
        @h4 "#{label}"
        @ul class: 'items', =>
          for url in contents
            @li class: 'item', url: url, =>
              @img src: resources[url].image
              @div class: 'text', =>
                @h2 resources[url].name
                @subview 'signal', Signal.withOutcomes(decodeURIComponent(url), outcomes[url])
