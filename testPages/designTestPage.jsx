var React          = require('react'),
 AutocompleteField = require('./src/design/AutocompleteField.jsx'),
 ExpandingList     = require('./src/design/ExpandingList.jsx'),
 ExpandingToggle   = require('./src/design/ExpandingToggle.jsx'),
 WordChoice        = require('./src/design/WordChoice.jsx')



document.head.insertAdjacentHTML('beforeend', '<link rel="stylesheet" href="vendor/ratchet/css/ratchet.css">');




class TestPage extends React.Component {

  constructor(props){
    super(props)
    this.state = {
      word: 'adaptable',
      toggle: false,
    }
    this.onWordChange = this.onWordChange.bind(this)
    this.onToggle = this.onToggle.bind(this)
  }

  onWordChange(word){
    this.setState({word: word})
  }

  expansionForChild(child){
    return <li className="table-view-cell">I'm an expansion for {
      child
    }!</li>
  }

  onChange(foo){
    console.log("Autocompleted " + foo)
  }

  onToggle(foo){
    this.setState({toggle: !this.state.toggle})
  }

  render(){
    return <div className="content">


      <h2>Expanding List</h2>

      <ExpandingList expander={this.expansionForChild}>
        <li className="table-view-cell" key="fee">Fee</li>
        <li className="table-view-cell" key="fi">Fi</li>
        <li className="table-view-cell" key="fo">Fo</li>
        <li className="table-view-cell" key="fum">Fum</li>
      </ExpandingList>



      <h2>Word Choice</h2>

      <p>
        This is a paragraph with an <WordChoice currentOption={this.state.word} onChange={this.onWordChange} options={['adaptable', 'stupid']}/> word.
      </p>

      <h2>Expanding Toggle</h2>

      <ul className="table-view">
        <ExpandingToggle open={this.state.toggle} text="Choose me to expand" onToggle={this.onToggle}>
          <li className="table-view-cell">
            Which will allow you to see this awesome additional text.
          </li>
        </ExpandingToggle>
      </ul>




      <h2>Autocomplete Field</h2>

      <AutocompleteField
          placeholder="Type something"
          completions={x => [ 'Alpha', 'Beta', 'Gamma' ].map(x =>
            <li className="table-view-cell">{x}</li>
          )}
          onChange={this.onChange}
      />


    </div>
  }

}

React.render( <TestPage/>, document.body )
