import React from 'react'

export default class ReasonRow extends React.Component {
  render(){
    // console.log('ReasonRow has reasonId', reasonId)
    var { reasonId, cx, engagement, onClick, comment } = this.props
    var { type, title } = cx.reasonData(reasonId)
    var { icon, phrase, color } = cx.getDisposition(reasonId, engagement.url)

    return <li
      className={`table-view-cell ReasonRow ${color}`}
      onClick={onClick}
      >
      <span className={`icon ${icon}`} />
      <div className={`reason ${color}`}><b>{title}</b></div>
      <div className="intro">{phrase}</div>
      { comment && <p>{comment}</p> }
    </li>
  }
}
