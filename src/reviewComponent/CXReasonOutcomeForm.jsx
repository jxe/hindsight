import React from 'react'
import {
  HowManyTimesSlider,
  HowOftenSlider,
  WhenDidYouFirstSlider,
  AreYouNowToggle
} from './TimelineFormElements.jsx'



export default class CXReasonOutcomeForm extends React.Component {
  render(){
    var [ type, name ] = this.props.reasonId.split('/')
    return (type == 'equipment') ?
      <HopeForm    {...this.props} /> :
      <FeatureForm {...this.props} />
  }
}



class HopeForm extends React.Component {
  render(){
    var {reasonId, cx, engagement} = this.props
    var [ reasonType, reasonName ] = reasonId.split('/')
    var payoffs = cx.getTrack(`${reasonId} fulfillment ${engagement.url}`)
    var atLeastOnePayoff = payoffs.occurrencesCount && payoffs.occurrencesCount != '0'
    var pass = { cx: cx, window: engagement.usage.window }

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
        text={`How many times over ${engagement.length} has ${engagement.name} got me ${reasonName}?`}
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



class FeatureForm extends React.Component {
  render(){
    var {reasonId, cx, engagement} = this.props
    var [ reasonType, reasonName ] = reasonId.split('/')
    var pass = { cx: cx, window: engagement.usage.window }

    return <div className="expansion">
      <HowOftenSlider {...pass}
        for={`${reasonId} vision`}
        text="I want to spend"
        unit="hrs/wk"
      />
      <HowOftenSlider {...pass}
        for={`${reasonId} fulfillment ${engagement.url}`}
        during={engagement}
        text={`During how much of ${engagement.name} are you ${reasonName}?`}
        unit="hrs/wk"
      />
      <AreYouNowToggle {...pass}
        for={`${reasonId} regret ${engagement.url}`}
        text={`There are alternatives to ${engagement.name} that are more compatible with ${reasonName} and these would have been better for me.`}
      />
    </div>
  }
}
