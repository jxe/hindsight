import React from 'react'
import Pager from './Pager.jsx'

export default class Subpage extends React.Component {
  render(){
    return <div>
      <header className="bar bar-nav" onClick={Pager.pop}>
         <a className="icon icon-left-nav pull-left"></a>
        <h1 className="title">{this.props.title}</h1>
      </header>
      <div className="content">
        {this.props.children}
      </div>
    </div>
  }
}
