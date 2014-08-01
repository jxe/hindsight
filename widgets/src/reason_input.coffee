window.lozenge = (color, tagname) ->
  $$$ ->
    @div class: "hindsight-lozenge #{color}", =>
      @span class: 'gem'
      @span class: 'text', =>
        @b tagname



class window.ReasonInput extends Firecomplete
  @content: (hint) ->
    super(hint:hint)
  initialize: (hint, onchoose) ->
    super
      hint: hint,
      fb: fb('tags'),
      onchoose: onchoose,
      renderer: (obj) ->
        return "Add #{obj.name}" if obj.adder
        return lozenge('well', obj.name)
      onadded: (str) ->
        alert('new reason...')
#        fb('tags').child(str).set name: str

  
#           return [
#              name: "activity: #{typed}"
#              name: "faculty: #{typed}"
#              name: "image: #{typed}"
#              name: "asset: #{typed}"
#              name: "feeling: #{typed}"
#            ]
  
