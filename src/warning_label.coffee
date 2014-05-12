class window.WarningLabel extends View
  @content: (tagdata, userdata) ->
    @span class: 'tagfield', =>
      tags_with_data = []
      for tag, data of tagdata
        if data
          data.going_well_count = Object.keys(data.going_well_for || {}).length
          data.going_poorly_count = Object.keys(data.going_poorly_for || {}).length
          data.total = data.going_well_count + data.going_poorly_count
          tags_with_data.push tag if data.total
      top_tags = tags_with_data.sort (a,b) ->
        if tagdata[a].total > tagdata[b].total then -1 else 1
      top_tags = top_tags.slice(0, 3)
      for tag in top_tags
        data = tagdata[tag]
        if data && data.total > 0
          going_well_percent = data.going_well_count / data.total
          going_poorly_percent = data.going_poorly_count / data.total
          userdata = userdata?[tag]
          [ type, tagname ] = tag.split(': ')

          # lets say 10 by 20
          r1w = r2x = going_well_percent * 14
          r2w = 14 - r1w

          svg = "<svg><rect fill='rgb(121, 211, 121)' x='0' y='0' width='#{r1w}' height='6'/><rect fill='rgb(196, 108, 108)' x='#{r2x}' y='0' width='#{r2w}' height='6'/></svg>"

          @b class: "#{type} #{userdata?.now}", =>
            @raw svg
            # @img src: "img/#{type}.png"
            @text tagname
          @text ' '
