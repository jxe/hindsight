class window.WarningLabel extends View
  @content: (tagdata, userdata) ->
    @span class: 'tagfield', =>
      for tag, data of tagdata
        if data
          userdata = userdata?[tag]
          [ type, tagname ] = tag.split(': ')
          going_well_count = Object.keys(data.going_well_for || {}).length
          going_poorly_count = Object.keys(data.going_poorly_for || {}).length
          total = going_well_count + going_poorly_count
          if total > 0
            going_well_percent = going_well_count / total
            going_poorly_percent = going_poorly_count / total

            # lets say 10 by 20
            r1w = r2x = going_well_percent * 14
            r2w = 14 - r1w

            svg = "<svg><rect fill='green' x='0' y='0' width='#{r1w}' height='8'/><rect fill='red' x='#{r2x}' y='0' width='#{r2w}' height='8'/></svg>"

            @b class: "#{type} #{userdata?.now}", =>
              @raw svg
              @img src: "img/#{type}.png"
              @text tagname
            @text ' '
