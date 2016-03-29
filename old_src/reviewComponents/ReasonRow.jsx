import React from 'react'
import Pager from './controls/Pager.jsx'
import ReasonIsFurtherancePage from './ReasonIsFurtherancePage.jsx'
import ReasonIsExperiencePage from './ReasonIsExperiencePage.jsx'
import inEnglish from './inEnglish.js'

export default class ReasonRow extends React.Component {
  render(){
    // console.log('ReasonRow has reasonId', reasonId)
    var { reasonId, cx, engagement, onClick, comment } = this.props
    var { type, title } = cx.reasonData(reasonId)
    var { icon, phrase, color } = inEnglish.getDisposition(cx, reasonId, engagement.url)

    return <li
      className={`table-view-cell ReasonRow ${color}`}
      onClick={this.show.bind(this)}
      >
        <a className="navigate-right">
          <span className={`icon ${icon}`} />
          <div className={`reason ${color}`}><b>{title}</b></div>
          <div className="intro">{phrase}</div>
          { comment && <p>{comment}</p> }
        </a>
    </li>
  }

  show(){
    var { cx, reasonId } = this.props
    var { type } = cx.reasonData(reasonId)
    var Page;
    if (type == 'furtherance') Page = ReasonIsFurtherancePage;
    else Page = ReasonIsExperiencePage;
    Pager.push(<Page {...this.props} />)
  }
}
