# TODO  @fromUrl: (url) ->

store_domains =
  'itunes.apple.com': true
  'www.amazon.com': true

class window.Resource
  
  # construction
  
  constructor: (@url, @title) ->
    @canonUrl = Resource.canonicalize(url)
  
  @fromChromeTab: (tab) ->
    r = new Resource(tab.url, tab.title)
    # r.store()
    r
  
  @fromFirebaseObject: (obj) ->
    r = new Resource(obj.url, obj.title || obj.name)
    r

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
    Review.fromResourceAndUser(this, uid)
    
    
  # key algorithms
  
  name: ->
    switch @type()
      when 'app', 'product', 'city', 'venue'
        return @title
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
    return 'product' if @canonUrl.match(/amazon|stripe|square|etsy|groupon/)
    return 'venue'   if @canonUrl.match(/yelp|foursquare/)
    return 'website'

  
  # reviewing
  
  goingWellFor: (uid, tag) ->
    p = @firebase_path()

    resource = fb('resources/%', p)
    resource.fb('tags/%/going_poorly_for', tag).remove_user()
    resource.fb('tags/%/going_well_for', tag).add_user()
    resource.touch()
    
    fb('outcomes/%/%', uid, p).child(tag).update going: 'well'
    fb('engagements/%/%', uid, p).update type: 'used'
    
  
  # persistence
  
  fetchMetadata: (cb) ->
    # use a service to get the title; TODO: use chrome xhr directly
    $.ajax
      url: "http://retroreview.herokuapp.com/url/" + encodeURIComponent(url),
      dataType: 'json',
      success: (data) ->
        r.title = data.title
        r.image = data.image
        # @store()
        cb(r)

  firebase_path: =>
    encodeURIComponent(@canonUrl).replace(/\./g, '%2E')
    
  store: =>
    fb('resources').child(@firebase_path()).update
      url: @canonUrl,
      title: @title,
      name: @name(),
      types: [@type()]
  


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
  # FIXME: mocked :)
  situate: (current_resource_for_desire, best_options) ->
    return 'mixed'
  label: (type) ->
    switch type
      when 'good'
        return 'good reviews'
      when 'mixed'
        return 'mixed reviews'
      when 'poorly'
        return 'going poorly'
      when 'well'
        return 'going well'
      else
        return type

      
# OLDER, TO REMOVE


#  @for_url: (url, cb) ->
#    fb('resources/%', Links.asFirebasePath(url)).on 'value', (snap) =>
#      v = snap.val()
#      return cb(Review.for_obj(v)) if v
#      Links.info url, (canonical_url, shortname, longname, img) ->
#        obj =
#          url: canonical_url
#          name: shortname
#          type: Links.resourceType(canonical_url)
#        fb('resources').child(Links.asFirebasePath(canonical_url)).set obj
#        cb(Review.for_obj(obj))
#  




window.Links =
  info: (url, cb) =>
    url = Links.canonicalize(url)
    $.ajax
      url: "http://retroreview.herokuapp.com/url/" + encodeURIComponent(url),
      dataType: 'json',
      success: (data) ->
        cb(url, data.title, data.title, data.img);

  canonicalize: (url) ->
#    return url
    return unless url
    return url unless url.match(/^http/)
    match = url.match(/:\/\/(.[^/]+)/)
    return url unless match
    return "https://" + (match[1]).replace('www.','')

  asFirebasePath: (url) =>
    return encodeURIComponent(Links.canonicalize(url)).replace(/\./g, '%2E')

  resourceType: (data)->
    return '' unless data
    link = data.url || data.name || data;
    if link.match(/city/)
      return 'city'
    else if link.match(/itunes|play/)
      return 'app'
    else if link.match(/amazon|stripe|square|etsy|groupon/)
      return 'product'
    else if link.match(/yelp|foursquare/)
      return 'venue'
    else
      return 'website'

  resourceLabel: (data)->
    return '' unless data
    link = data.url || data.name || data;
    if link.match(/vimeo|youtube/)
      return 'a video'
    else if link.match(/itunes|play/)
      return 'an app'
    else if link.match(/amazon|stripe|square|etsy|groupon/)
      return 'a product'
    else if link.match(/yelp|foursquare/)
      return 'a venue'
    else
      return 'a website'
