import React from 'react'
import TimelineUtil from '../collectiveExperience/timelineUtilities.js'

export default class UsageSummary extends React.Component {
  render(){
    TimelineUtil.addSummaryData(this.props.engagement)
    var {name, minutesPerWeek, windowInWeeks, favIconUrl} = this.props.engagement
    return <div className="usageSummary">
      <img src={favIconUrl} />
      <div>
        <h3>
          {minutesPerWeek}
          <small> minutes <small>each week</small></small>
        </h3>
        <p><b>7</b> distinct activities</p>
      </div>
    </div>
  }
}

// over
// <b>${windowInWeeks} weeks</b>
