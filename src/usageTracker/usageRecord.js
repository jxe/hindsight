// UsageRecord


// TODO:  keep visited URLs somewhere for analysis / summary



export default {

  add(t, dt, url, title, blame_url){
    var weekNo = this.weekNo(t)
    this.ensureWeek(url, weekNo)
    this.addToBouts(`${url}/direct/${weekNo}`, t, dt)

    if (blame_url){
      this.ensureWeek(blame_url, weekNo)
      this.addToBouts(`${blame_url}/indirect/${weekNo}`, t, dt)
    }
  },

  allBouts(url, type){
    var bouts = []
    this.fetch('WEEKS', url).forEach( weekNo => {
      bouts = bouts.concat(this.fetch('BOUTS', `${url}/${type}/${weekNo}`))
    })
    return bouts
  },



  // internals

  weekNo(t){
    t = t*1000
    var start = t ? new Date(t) : new Date();
		var first = start.getDate() - start.getDay();
		start.setDate(first);
		start.setHours(0,0,0,0);
		return Math.floor(start.getTime() / 1000);
  },

  ensureWeek(url, weekNo){
    var weeks = this.fetch('WEEKS', url)
    if (weeks[weeks.length - 1] != weekNo)
    weeks.push(weekNo)
    this.store('WEEKS', url, weeks)
  },

  addToBouts(label, t, dt){
    var bouts = this.fetch('BOUTS', label)
    var lastBout = bouts[bouts.length - 1]
    if (lastBout && (t - lastBout[1] < 30)){
      lastBout[1] = (t + dt)
      return this.store('BOUTS', label, bouts)
    } else {
      bouts.push([t, t+dt])
      this.store('BOUTS', label, bouts)
    }
  },

  fetch(type, identifier, default_object){
    if (!default_object) default_object = []
    var str = localStorage[`${type}: ${identifier}`]
    return str ? JSON.parse(str) : default_object
  },

  store(type, identifier, data){
    localStorage[`${type}: ${identifier}`] = JSON.stringify(data)
  }
}
