import React from 'react/addons'


export default class ExpandingList extends React.Component {

  constructor(props){
    super(props)
    this.state = {}
    this.toggleChild = this.toggleChild.bind(this)
    this.render = this.render.bind(this)
  }

  toggleChild(key){
    if (this.state.key == key) return this.setState({key:null})
    else return this.setState({key: key})
  }

  show(key){
    this.setState({key: key})
  }

  render(){
    var things = []

    React.Children.forEach(this.props.children, c => {
      var e = React.cloneElement(c, {onClick: this.toggleChild.bind(this, c.key)})
      things.push(e)
      if (e.key && e.key == (this.state && this.state.key)){
        var exp = this.props.expander(e.key)
        exp = React.cloneElement(exp, {key: `${e.key} expansion`})
        things.push(exp)
      }
    })

    return <ul className="table-view">
      <React.addons.CSSTransitionGroup transitionName="elist">
        {things}
      </React.addons.CSSTransitionGroup>
    </ul>
  }

}
