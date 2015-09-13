import React from 'react/addons'
var current;

export default class Pager extends React.Component {

  constructor(props){
    super(props)
    this.state = { stack: [] }
    current = this
  }

  static push(child){ current.push(child) }
  static pop(){ current.pop() }

  push(child){
    var { stack } = this.state
    stack.unshift(child)
    this.setState({ direction: 'right', stack: stack })
  }

  pop(){
    var { stack } = this.state
    stack.shift()
    this.setState({ direction: 'left', stack: stack })
  }

  render(){
    var { stack, direction } = this.state
    return (
      <React.addons.CSSTransitionGroup
        transitionName={`page-${direction}`}
        component="div"
        className="Pager"
      >
        {stack[0] || this.props.children}
      </React.addons.CSSTransitionGroup>
    )
  }

}
