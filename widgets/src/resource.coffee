# TODO  @fromUrl: (url) ->

store_domains =
  'itunes.apple.com': true
  'www.amazon.com': true

class window.Resource
  @fromChromeTab: (tab) ->
    r = new Resource(tab.url, tab.title)
#    r.store()
    r
  
  @canonicalize: (url) ->
    url = url.replace(/(\#|\?).*$/, '')
    m = url.match(/(\w+):\/\/(.[^\/]+)/)
    [ _, scheme, domain ] = m
    if !store_domains[domain]
      return "#{scheme}://#{domain}"
    else
      return url
  
  constructor: (@url, @name) ->
    @canonUrl = Resource.canonicalize(url)

  firebase_path: =>
    encodeURIComponent(@canonUrl).replace(/\./g, '%2E')
  
  store: =>
    fb('resources').child(@firebase_path()).update
      url: @canonUrl,
      name: @name,
      types: @types()
  
  reviewByUser: (uid) ->
    Review.fromResourceAndUser(this, uid)
    
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



# OLDER, TO REMOVE

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
