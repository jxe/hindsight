var phrases = {
  equipment: {
    pending: 'may lead to',
    fulfilled: 'led to',
    regretted: 'didn\'t lead to',
    regrettedAnyways: 'led to'
  },
  activity: {
    pending: 'may include',
    fulfilled: 'includes',
    regretted: 'doesn\'t include',
    regrettedAnyways: 'conflicted for'
  }
}

var icons = {
  equipment: {
    pending: 'icon-more',
    fulfilled: 'icon-check',
    regretted: 'icon-close',
    regrettedAnyways: 'icon-check'
  },
  activity: {
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

  currentValue(track){
    if (track.samples) return track.samples[track.current]
    // ... could also support bouts
    return 0
  },

  updateValue(track, value, atTime){
    if (!atTime) atTime = Date.now()
    if (!track.samples){
      return {
        current: atTime,
        samples: { [atTime]: value }
      }
    }

    var newTrack = {
      current: track.current,
      samples: Object.assign({}, track.samples)
    }

    if (Math.abs(track.current - atTime) < 10*60*1000){
      delete newTrack.samples[track.current]
      delete newTrack.current
    }

    newTrack.samples[atTime] = value
    if (!newTrack.current || newTrack.current < atTime) newTrack.current = atTime
    return newTrack
  },

  htmlSummary(track){
    var mpw = Math.floor(this.getMedianSecondsPerWeek(track) / 60)
    var weeks = Math.ceil((track.window[1] - track.window[0]) / (60*60*24*7))
    return `<div class="usageSummary">${weeks} weeks @ ${mpw} minutes/week</div>`
  },

  getMedianSecondsPerWeek(track){
    if (track.regular) return track.regular.seconds
    if (track.bouts){
      var secondsByWeek = {}
      track.bouts.forEach( b => {
        var week = Math.floor(b[0]/(60*60*7*24))
        var seconds = b[1] - b[0]
        if (!secondsByWeek[week]) secondsByWeek[week] = 0
        secondsByWeek[week] += seconds
      })
      var sorted = Object.values(secondsByWeek)
      return sorted[Math.floor(sorted.length/2)]
    }
    return null
  },

  resourceStatus(tracks){
    var fulfilled = tracks.fulfillment && (tracks.fulfillment.occurrencesCount || tracks.fulfillment.regular.seconds)
    var regretted = this.currentValue(tracks.regret || {})

    if (regretted && fulfilled) return 'regrettedAnyways'
    if (!regretted && !fulfilled) return 'pending'
    if (regretted) return 'regretted'
    else return 'fulfilled'
  },

  disposition(concern, tracks){
    var [ type, name ] = concern.split('/')
    var status = this.resourceStatus(tracks)
    console.log('status', status, concern, tracks)
    return {
      phrase: phrases[type][status],
      icon: icons[type][status],
      color: colors[status]
    }
  }

}
