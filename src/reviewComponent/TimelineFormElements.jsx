import React from 'react'
import TimelineUtil from '../collectiveExperience/timelineUtilities.js'


export class AbstractTimelineSlider extends React.Component {
  onChange(){
    var trackData = this.trackForValue()
    if (!trackData.window) trackData.window = this.props.window
    this.props.cx.setTrack(this.props.for, trackData)
  }

  track(){
    return this.props.cx.getTrack(this.props.for)
  }

  render(){
    return <li className="table-view-cell">
      <p>{this.props.text}</p>
      <input ref="input" type="range"
        onChange={this.onChange.bind(this)}
        value={this.currentValue()}
        max={this.max()}
      />
      <div>{this.desc()}</div>
    </li>
  }
}


export class AreYouNowToggle extends AbstractTimelineSlider {
  currentValue(){
    return this.props.cx.getCurrentValue(this.props.for)
  }

  onToggle(){
    var { cx } = this.props
    cx.toggleValue(this.props.for, this.props.window)
  }

  render(){
    return <li className="table-view-cell" onClick={this.onToggle.bind(this)}>
      {this.props.text}
      <div className={`toggle ${this.currentValue() && 'active'}`}>
        <div className="toggle-handle"></div>
      </div>
    </li>
  }
}


export class HowOftenSlider extends AbstractTimelineSlider {
  trackForValue(){
    var el = React.findDOMNode(this.refs.input)
    return { regular: { seconds: el.value, every: 604800 } }
  }

  currentValue(){
    var t = this.track()
    return t.regular ? t.regular.seconds : 0
  }

  desc(){
    var hrspwk = Math.floor(this.currentValue() / 60 / 60)
    return `${hrspwk} h/wk`
  }

  max(){
    var { during } = this.props
    var median = during && TimelineUtil.getMedianSecondsPerWeek(during)
    return median || 352800
  }
}


export class HowManyTimesSlider extends AbstractTimelineSlider {
  trackForValue(){
    var el = React.findDOMNode(this.refs.input)
    return { occurrencesCount: el.value }
  }

  currentValue(){
    var t = this.track()
    return t.occurrencesCount || 0
  }

  desc(){
    return `${this.currentValue()} times`
  }

  max(){
    return 20
  }
}


export class WhenDidYouFirstSlider extends AbstractTimelineSlider {
  trackForValue(){
    var { window } = this.props
    var el = React.findDOMNode(this.refs.input)
    var t = el.value + window[0]
    return { occurrences: [t] }
  }

  currentValue(){
    var { window } = this.props
    var track = this.track()
    var t = track.occurrences ? track.occurrences[0] : 0
    return t - window[0]
  }

  desc(){
    var { window } = this.props
    var t0 = window && window[0] || 0
    var weeks = Math.floor(this.currentValue() / 604800)
    return `after ${weeks} weeks`
  }

  max(){
    var { window } = this.props
    if (window) return window[1] - window[0]
    else return 604800 * 52
  }
}
