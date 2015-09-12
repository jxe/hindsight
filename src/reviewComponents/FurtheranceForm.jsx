import React from 'react'
import {
  HowManyTimesSlider,
  HowOftenSlider,
  WhenDidYouFirstSlider,
  AreYouNowToggle
} from './TimelineFormElements.jsx'
import TimelineUtil from '../collectiveExperience/timelineUtilities.js'

export default class FurtheranceForm extends React.Component {
  render(){
    var {reasonId, cx, engagement} = this.props
    var { title } = cx.reasonData(reasonId)
    var payoffs = cx.getTrack(`${reasonId} fulfillments ${engagement.url}`)
    var atLeastOnePayoff = payoffs.occurrencesCount && payoffs.occurrencesCount != '0'
    var pass = { cx: cx, window: engagement.usage.window }
    var weeksOfUse = TimelineUtil.windowInWeeks(engagement.usage)

    return <div className="expansion">
      <AreYouNowToggle {...pass}
        text={`${title} is something I want`}
        for={`${reasonId} hopes`}
      />
      <HowOftenSlider {...pass}
        during={engagement.usage}
        for={`${reasonId} usage ${engagement.url}`}
        text={`How much of your use is for ${title}`}
      />
      <HowManyTimesSlider {...pass}
        text={`How many times over ${weeksOfUse} weeks of use has ${engagement.name} got me ${title}?`}
        for={`${reasonId} fulfillments ${engagement.url}`}
      />

      {
        atLeastOnePayoff &&
        <WhenDidYouFirstSlider {...pass}
          for={`${reasonId} fulfillments ${engagement.url}`}
          during={``}
          text="What long did it take the first time?"
        />
      }

      <AreYouNowToggle {...pass}
        reversed={true}
        for={`${reasonId} reflections ${engagement.url}`}
        text={`There are alternatives to ${engagement.name} which would have required less of an investment, and these would have been better for me.`}
      />
    </div>
  }
}
