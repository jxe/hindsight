import TimelineUtil from '../collectiveExperience/timelineUtilities.js'


var phrases = {
  furtherance: {
    pending: 'a result you and 7 others are after',
    fulfilled: 'a result you got from this',
    regretted: 'a result you didn\'t get from this',
    regrettedAnyways: 'a result you wanted'
  },
  experience: {
    pending: 'an experience you and 7 others want',
    fulfilled: 'an experience you get from this',
    regretted: 'an experience you wanted from this',
    regrettedAnyways: 'an experience you got from this'
  }
}

var icons = {
  furtherance: {
    pending: 'icon-more',
    fulfilled: 'icon-check',
    regretted: 'icon-close',
    regrettedAnyways: 'icon-check'
  },
  experience: {
    pending: 'icon-more',
    fulfilled: 'icon-check',
    regretted: 'icon-close',
    regrettedAnyways: 'icon-close'
  }
}

var colors = {
  pending: 'neutral',
  fulfilled: 'positive',
  regretted: 'negative',
  regrettedAnyways: 'negative'
}



export default {

  hopes: ['more often', 'less often', "don't care"],

  getHopes(cx, reasonId){
    var t = cx.getTrack(`${reasonId} hopes`)
    if (t.regular && t.regular.seconds) return 'more often'
    else return "don't care"
  },

  setHopes(cx, reasonId, disposition){
    var t = cx.getTrack(`${reasonId} hopes`)
    t.regular.seconds = {
      'more often': 60*60,
      'less often': -1,
      "don't care": 0
    }[disposition]
    cx.setTrack(`${reasonId} hopes`, t)
  },


  //....


  furtheranceHopes: ['want', "used to want"],

  getFurtheranceHopes(cx, reasonId){
    var t = cx.getCurrentValue(`${reasonId} hopes`)
    return t ? 'want' : 'used to want';
  },

  setFurtheranceHopes(cx, reasonId, disposition){
    var x = cx.getCurrentValue(`${reasonId} hopes`)
    var newTimeline = TimelineUtil.updateValue(x, {
      'want': 1,
      'used to want': 0
    }[disposition])
    cx.setTrack(`${reasonId} hopes`, newTimeline)
  },



  //....

  reflections: ["yes", "no", "still deciding"],

  getReflections(cx, resource, reasonId){
    var x = cx.getCurrentValue(`${reasonId} reflections ${resource}`)
    if (x==0) return 'still deciding'
    if (x>0) return 'yes'
    if (x<0) return 'no'
  },

  setReflections(cx, resource, reasonId, reflection){
    var x = cx.getCurrentValue(`${reasonId} reflections ${resource}`)
    var newTimeline = TimelineUtil.updateValue(x, {
      'yes': 1,
      'no': -1,
      'still deciding': 0
    }[reflection])
    cx.setTrack(`${reasonId} reflections ${resource}`, newTimeline)
  },


  //....

  getDisposition(cx, reason, resource){
    var tracks = cx.getTracks(reason, resource)
    var type = cx.reasons[reason].type
    var status = TimelineUtil.resourceStatus(tracks)
    return {
      phrase: phrases[type][status],
      icon: icons[type][status],
      color: colors[status]
    }
  }

}


// <AreYouNowToggle {...pass}
//   reversed={true}
//   for={`${reasonId} reflections ${engagement.url}`}
//   text={`There are alternatives to ${engagement.name} that are more compatible with ${title} and these would have been better for me.`}
// />
