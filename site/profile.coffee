# todo replace with react-coffee

sections =
  app: 'Apps'
  city: 'Cities'
  website: 'Websites'

class window.Profile extends View
  @content: (person, resources, engagements, desires) ->
    @div =>
      @header =>
        @img src: person.photo
        @h2 person.name
      for type, label of sections
        contents = Object.keys(resources).filter((url) -> resources[url]?.type == type)
        @h4 "#{label} reviewed"
        @ul =>
          for url in contents
            @li class: 'item', url: url, =>
              @img src: resources[url].icon
              @h2 resources[url].name
      @h4 'Goals'
      @ul =>
        for desire, info of desires
          @li =>
            @b desire
            @p "still_desired: #{info.still_desired}"
