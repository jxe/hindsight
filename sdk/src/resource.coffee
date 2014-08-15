# TODO  @fromUrl: (url) ->
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

store_domains =
  'itunes.apple.com': true
  'www.amazon.com': true
  'www.npmjs.org': true

class window.Resource
  
  # construction
  
  constructor: (@url, @title) ->
    @canonUrl = Resource.canonicalize(url)
  
  @fromChromeTab: (tab) ->
    r = new Resource(tab.url, tab.title)
    r.store()
    r
  
  @fromFirebaseObject: (obj) ->
    r = new Resource(obj.url, obj.title || obj.name)
    r
  
  @fromUrlWithoutMetadata: (url) ->
    new Resource(url)

  @fromUrl: (url, callback) ->
    url = "http://#{url}" unless url.match(/^http/)
    unless url.match(/(\w+):\/\/(.[^\/]+)/)
      callback 'error'
      return 'error'
    r = new Resource(url)
    if r.type() != 'website'
      r.fetchMetadata ->
        callback r
    callback r

  # related objects
  
  reviewByUser: (uid) ->
    ResourceExperienceEditor.fromResourceAndUser(this, uid)
    
    
  # key algorithms
  
  name: ->
    switch @type()
      when 'app', 'product', 'city', 'venue'
        return @title || @canonUrl
      else
        return @domain()
  
  domain: ->
    @canonUrl.match(/(\w+):\/\/(.[^\/]+)/)[2]
  
  @canonicalize: (url) ->
    url = url.replace(/(\#|\?).*$/, '')
    m = url.match(/(\w+):\/\/(.[^\/]+)/)
    [ _, scheme, domain ] = m
    if !store_domains[domain]
      return "#{scheme}://#{domain}"
    else
      return url
  
  type: ->
    return 'city'    if @canonUrl.match(/city/)
    return 'app'     if @canonUrl.match(/itunes|play/)
    return 'product' if @canonUrl.match(/amazon|stripe|square|etsy|groupon|npmjs/)
    return 'venue'   if @canonUrl.match(/yelp|foursquare/)
    return 'website'

  
  # reviewing
  
  outcomesForUser: (uid, value, outcomes) ->
    console.log 'setting: ', outcomes
    fb('experience/%/resources/%/for/%', uid, @firebase_path(), value.id).set outcomes


  
  # persistence
  
  fetchMetadata: (cb) =>
    # use a service to get the title; TODO: use chrome xhr directly
    $.ajax
      url: "http://retroreview.herokuapp.com/url/" + encodeURIComponent(@url),
      dataType: 'json',
      success: (data) =>
        @title = data.title
        @image = data.image
        @store()
        cb(this)

  firebase_path: =>
    encodeURIComponent(@canonUrl).replace(/\./g, '%2E')
  @from_firebase_path: (x) ->
    decodeURIComponent(x)
  
  store: =>
    fb('resources').child(@firebase_path()).update
      url: @canonUrl,
      title: @title,
      name: @name(),
      types: [@type()]
  
