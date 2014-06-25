window.gerunds =
  buy: 'buying'
  visit: 'visiting'
  watch: 'watching'
  listen: 'listening'
  read: 'reading'

window.pasttense =
  buy: 'bought'
  visit: 'visited'
  watch: 'watched'
  listen: 'listened'
  read: 'read'

window.Desires =
  # TODO: implement personalization of desires for signals
  personalize: (user_desires, common_desires) ->
    top_desires = []
    for tag, taginfo of common_desires
      taginfo.id = tag
      top_desires.push taginfo
    return top_desires
  strong_migrations: (related_desires) ->
    return true

window.Ratings =
  # FIXME: all good :)
  situate: (current_resource_for_desire, best_options) ->
    return 'good'
