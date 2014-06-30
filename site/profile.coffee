# todo replace with react-coffee

sections =
  app: 'Apps'
  city: 'Cities'
  website: 'Websites'


class window.Profile extends View
  @load_into: (domid, uid) ->
    fb('people/%', uid)
      .plus fb('desires/%', uid)
      .plus fb('engagements/%', uid), (v, q) ->
        for url, engagement of v
          q.plus fb('resources/%', url)
      .on_full_value (v) ->
        v = v[Object.keys(v)[0]]
        console.log(v)
        euid = encodeURIComponent(uid)
        $(domid).html(new Profile(v.people[euid], v.resources || {}, v.engagements[euid] || {}, v.desires[euid] || {}))

  @content: (person, resources, engagements, desires) ->
    @div =>
      @header =>
        @img src: person.photo
        @h2 person.name
      @subview 'search', new SearchToReview(fb('resources'))
      for type, label of sections
        contents = Object.keys(resources).filter((url) -> resources[url]?.type == type)
        @h4 "#{label} reviewed"
        @ul =>
          for url in contents
            @li class: 'item', url: url, =>
              @img src: resources[url].icon
              @h2 resources[url].name
              # @subview 'signal', new Signal(url, null, EXAMPLE_DATA.common_desires[url], EXAMPLE_DATA.best_options, EXAMPLE_DATA.related_desires)
      @h4 'Goals'
      @ul =>
        for desire, info of desires
          @li =>
            @b desire
            @p "still_desired: #{info.still_desired}"
