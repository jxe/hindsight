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
