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

  windowInWeeks(track){
    return Math.ceil((track.window[1] - track.window[0]) / (60*60*24*7))
  },

  addSummaryData(tracks){
    var secondsPerWeek = this.getMedianSecondsPerWeek(tracks.usage)
    tracks.minutesPerWeek = Math.floor(secondsPerWeek / 60)
    tracks.windowInWeeks = this.windowInWeeks(tracks.usage)
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

      var sorted = Object.keys(secondsByWeek).map(x => secondsByWeek[x])
      return sorted[Math.floor(sorted.length/2)]
    }
    return null
  },

  resourceStatus(tracks){
    var fulfilled = tracks.fulfillments && (tracks.fulfillments.occurrencesCount || tracks.fulfillments.regular.seconds)
    var regretted = (this.currentValue(tracks.reflections || {}) == -1)

    if (regretted && fulfilled) return 'regrettedAnyways'
    if (!regretted && !fulfilled) return 'pending'
    if (regretted) return 'regretted'
    else return 'fulfilled'
  },

  disposition(type, tracks){
    var status = this.resourceStatus(tracks)
    return {
      phrase: phrases[type][status],
      icon: icons[type][status],
      color: colors[status]
    }
  }

}
