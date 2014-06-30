window.Links =
  info: (url, cb) =>
    url = Links.canonicalize(url)
    $.ajax
      url: "/url/" + encodeURIComponent(url),
      dataType: 'json',
      success: (data) ->
        cb(url, data.title, data.title, data.img);

  canonicalize: (url) ->
    return url
    return unless url
    return url unless url.match(/^http/)
    match = url.match(/:\/\/(.[^/]+)/)
    return url unless match
    return (match[1]).replace('www.','')

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
