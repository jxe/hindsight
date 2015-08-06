import React from 'react'
import {
  HowManyTimesSlider,
  HowOftenSlider,
  WhenDidYouFirstSlider,
  AreYouNowToggle
} from './TimelineFormElements.jsx'
import TimelineUtil from '../collectiveExperience/timelineUtilities.js'

export default class DeliversEquipmentForm extends React.Component {
  render(){
    var {reasonId, cx, engagement} = this.props
    var [ reasonType, reasonName ] = reasonId.split('/')
    var payoffs = cx.getTrack(`${reasonId} fulfillment ${engagement.url}`)
    var atLeastOnePayoff = payoffs.occurrencesCount && payoffs.occurrencesCount != '0'
    var pass = { cx: cx, window: engagement.usage.window }
    var weeksOfUse = TimelineUtil.windowInWeeks(engagement.usage)

    return <div className="expansion">
      <AreYouNowToggle {...pass}
        text={`${reasonName} is something I want`}
        for={`${reasonId} vision`}
      />
      <HowOftenSlider {...pass}
        during={engagement}
        for={`${reasonId} usage ${engagement.url}`}
        text={`How much of your use is for ${reasonName}`}
      />
      <HowManyTimesSlider {...pass}
        text={`How many times over ${weeksOfUse} weeks of use has ${engagement.name} got me ${reasonName}?`}
        for={`${reasonId} fulfillment ${engagement.url}`}
      />

      {
        atLeastOnePayoff &&
        <WhenDidYouFirstSlider {...pass}
          for={`${reasonId} fulfillment ${engagement.url}`}
          during={``}
          text="What long did it take the first time?"
        />
      }

      <AreYouNowToggle {...pass}
        for={`${reasonId} regret ${engagement.url}`}
        text={`There are alternatives to ${engagement.name} which would have required less of an investment, and these would have been better for me.`}
      />
    </div>
  }
}
