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
    this.setState({ direction: 'right', stack: stack.unshift(child) })
  }

  pop(){
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
