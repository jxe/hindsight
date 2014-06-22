window.EXAMPLE_DATA =

  # summary data, gathered up by the server...
  # (
  #   if you want to take demog/loc/etc into
  #   account, do your own analysis starting with the
  #   'reviews' and 'people' tables
  # )

  common_desires:
    "facebook.com":
      "activity: mindless reading":
        winner_percent: .1     # winner = someone for whom a (resource, outcome) pair is "going well"
        winners_use_for: '30h'
        winner_count: 1
        loser_count: 9
      "activity: flirting":
        winner_percent: .2
        winners_use_for: '10h'
        winner_count: 2
        loser_count: 8

  best_options:
    'activity: mindless reading':
      'itunes.com/random_app':
        winner_percent: .9
        winners_upfront_time: '5m'   # upfront_time = time required before you see an outcome you want
        winners_pay: 0
        type: 'event'
    'state: feeling relaxed':
      'yelp.com/dolores-park':
        type: 'venue'
        winner_percent: .9
        winners_upfront_time: '1h'
        winners_pay: 0

  related_desires:
    'activity: mindless reading':
      'state: feeling relaxed':
        forward_migrations: 6
        backward_migrations: 0




  # individual reviews

  reviews:
    'facebook:514190':
      'facebook.com':
        engagement:
          time: '50h'
          money: null
          usage_pattern: '???'
          as_of: 29820412
          starting: 120398123
          verified_by: 'firefox:TOKEN'
        outcomes:
          'activity: mindless reading':
            intended: true
            going: 'poorly'
            desire_abandoned: true
            replacement_desire: 'state: feeling relaxed'




  # detail info about objects

  resources:
    'facebook.com':
      icon: 'URL HERE'
      title: 'Facebook'
      reviewed_by: '...'
      reviewed_at: 149201298401
      url: 'http://facebook.com'

  people:
    'facebook:514190':
      name: 'Joe Edelman'
      facebook_id: '514190'
      photo: '...'
      city: '<WOEID>'
      birthyear: 1976
      gender: 'm'
      # TODO: add psychographic and sociographic info (urbanness/walkability, local_cohostables, local_invitables)

  outcomes:
    'state: feeling relaxed':
      canonical_name: 'feeling relaxed'
      type: 'state'
      kind_of: 'state: feeling good'
    'activity: distance biking':
      canonical_name: 'distance biking'
      type: 'activity'
      kind_of: 'activity: biking'
    'activity: biking':
      kind_of: 'activity: exercise'

  outcome_aliases:
    'state: feeling relaxed': [
      'getting relaxed'
      'being relaxed'
      'being chill'
      'feeling chill'
    ]
    'activity: distance biking': [
      'touring (bicycle)',
      'bike trips',
    ]


  # for more active users, profile information
  # FIXME: some of this data is redundant with review data

  user_profile_resources:
    'facebook:514190':
      'facebook.com':
        added: 109283121
        engaged_from: 1029830321
        engaged_until: 1203980123

  user_profile_desires:
    'facebook:514190':
      'state: feeling relaxed':
        added: 109283121
        desired_from: 1029830321
        desired_until: 1203980123
        replacement_desire: 'virtue: boldness'
