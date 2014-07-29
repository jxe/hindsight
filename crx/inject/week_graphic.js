/* Week Graph */

var week = d3.select("#week")

var hoursPerDay = [.5,.5,.5,.5,.5,.5, .5],
		days = ["M", "T", "W", "T", "F", "S", "S"]

function radius(d){ return Math.min(1, d)*60+10 }

var graph = week.selectAll('.day').data(hoursPerDay)

graph.enter()
		.append('div')
		.text(function(d, i){ return days[i]})
		.append('div')

function updateGraph(data){
	graph.data(data)

	graph.select('div>div').transition()
			.ease('elastic')
			.style({
				width: radius,
				height: radius,
				'top': function(d){ return radius(d)/2},
				'line-height': radius,
			})	

	var tWidth = d3.sum($('#week>div').map(function(){return $(this).width()}))
	console.log( tWidth )
}

function jiggleGraph(){
	updateGraph(d3.range(7).map(function(){
		return Math.random()
	}))
}


/* Page Graph */

var barData = [1,Math.random(),Math.random()].sort(function(a,b){return a<b})
var bars = d3.selectAll('.pages .bar').data(barData)

bars.transition()
	.ease('elastic')
	.style({
		width: function(d){ return d*200}
	})