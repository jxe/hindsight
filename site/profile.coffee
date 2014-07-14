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
    for url, url_outcomes of outcomes
      for outcome, info of url_outcomes
        desires[outcome] ||= {}
        if info.going
          desires[outcome]["going_"+info.going+"_for"] ||= {}
          desires[outcome]["going_"+info.going+"_for"][url] = info
    for desire, info of desires
      info.id = desire

    @div class:'profile', =>
      @header class: 'main content-padded', =>
        @img src: person.photo
        @div class: 'expando', =>
          @h2 person.name

          @h4 'Recent Goals'
          for desire, info of desires
            if info.still_desired
              @subview 'signal', Signal.withOutcome('', info)

          @h4 'Past goals'
          for desire, info of desires
            if !info.still_desired
              @subview 'signal', Signal.withOutcome('', info)

      @header class: 'white', =>
        @h3 "Reviews"
        @subview 'search', new SearchToReview(fb('resources'), 'Add apps or URLs')
      @section =>
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
