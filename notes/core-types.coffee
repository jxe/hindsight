resources:
  'facebook.com':
    image: 'http://facebook.com/favicon.ico'
    title: 'Facebook'
    url: 'http://facebook.com'
    types: ['app', 'website']

people:
  'facebook:514190':
    name: 'Joe Edelman'
    facebook_id: '514190'
    photo: 'https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xap1/t1.0-1/p50x50/10346047_10100265769347896_3000165581634871280_o.jpg'
    city: '<WOEID>'
    birthyear: 1976
    gender: 'm'

values:
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

engagements:
  'facebook:514190':
    'facebook.com':
      type: 'used'
      time: '50h'
      money: null
      timeline: '???'
      began_at: 120398123
      ended_at: 150398123
      reported_at: 220398123
      verified_by: 'firefox:TOKEN'
      public: true

concerns:
  'facebook:514190':
    'activity: mindless reading':
      still_desired: false
      led_to_desire: 'state: feeling relaxed'
      desired_on: 220398123
      desired_from: null
      desired_until: null
      public: true
      going_well_with:
        'itunes.com/randomapp': true
      going_poorly_with:
        'facebook.com'
    'state: feeling relaxed':
      desired_on: 1029830321
      desired_from: 1029830321
      desired_until: 1203980123
      still_desired: false
      led_to_desire: 'virtue: boldness'
      public: true

outcomes:
  'facebook:514190':
    'facebook.com':
      'activity: mindless reading':
        intended: true
        going: 'poorly'
        public: true
