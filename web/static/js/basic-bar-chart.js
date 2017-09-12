import * as d3 from 'd3';

export function renderChart(data) {
  var svg = d3.select('div#chart').append('svg');

  var margin = {
    left: 30,
    top: 30,
    right: 30,
    bottom: 30
  };

  svg.attr('width', window.innerWidth-200);
  svg.attr('height', window.innerHeight-100);

  var width = window.innerWidth - margin.left - margin.right-200;
  var height = window.innerHeight - margin.top - margin.bottom-100;

  var   chart = svg.append('g')
  .attr('width', width)
  .attr('height', height)
  .attr('transform', `translate(${margin.left}, ${margin.top})`);
  chart.attr('width', window.innerWidth-200)
  .attr('height', window.innerHeight-100);

  const x = d3.scaleBand()
  .domain(data.map(d => d.letter))
  .rangeRound([50, window.innerWidth - 250])
  .padding(0.1);

  const y = d3.scaleLinear()
  .domain([0, d3.max(data, d => d.presses)])
  .range([window.innerHeight - 150, 0]);

  const xAxis = d3.axisBottom().scale(x);
  const yAxis = d3.axisLeft().scale(y);

  chart.append('g')
  .attr('class', 'axis')
  .attr('transform', `translate(0, ${window.innerHeight - 150})`)
  .call(xAxis);

  chart.append('g')
  .attr('class', 'axis')
  .attr('transform', 'translate(50, 0)')
  .call(yAxis);

  chart.selectAll('rect')
  .data(data)
  .enter()
  .append('rect')
  .attr('class', 'bar')
  .attr('x', d => x(d.letter))
  .attr('y', window.innerHeight - 150)
  .attr('width', x.bandwidth())
  .attr('height', 0)
  .transition()
  .delay((d, i) => i * 20)
  .duration(800)
  .attr('y', d => y(d.presses))
  .attr('height', d =>
  (window.innerHeight - 150) - y(d.presses));
}

export function renderStackedChart(data) {
  var svg = d3.select('div#chart').append('svg');

  svg.attr('width', 400);
  svg.attr('height', 400);
  
  var margin = {top: 20, right: 20, bottom: 30, left: 40};
  var width = +svg.attr("width") - margin.left - margin.right;
  var height = +svg.attr("height") - margin.top - margin.bottom;
  var g = svg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var x = d3.scaleBand().rangeRound([0, width]).paddingInner(0.05).align(0.1);
var y = d3.scaleLinear().rangeRound([height, 0]);
var z = d3.scaleOrdinal().range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);


var keys = ["energy", "clothing"];

data.sort(function(a, b) { return b.total - a.total; });
x.domain(data.map(function(d) { return d.state; }));
y.domain([0, d3.max(data, function(d) { return d.total; })]).nice();
z.domain(keys);

var bb = d3.stack().keys(keys)(data);

g.append("g")
  .selectAll("g")
  .data(d3.stack().keys(keys)(data))
  .enter().append("g")
    .attr("fill", function(d) { return z(d.key); })
  .selectAll("rect")
  .data(function(d) { return d; })
  .enter().append("rect")
    .attr("x", function(d) { return x(d.data.state); })
    .attr("y", function(d) { return y(d[1]); })
    .attr("height", function(d) { console.log("height "+d[0] +" - " + d[1]); return y(d[0]) - y(d[1]); })
    .attr("width", x.bandwidth());

g.append("g")
    .attr("class", "axis")
    .attr("transform", "translate(0," + height + ")")
    .call(d3.axisBottom(x));

g.append("g")
    .attr("class", "axis")
    .call(d3.axisLeft(y).ticks(null, "s"))
  .append("text")
    .attr("x", 2)
    .attr("y", y(y.ticks().pop()) + 0.5)
    .attr("dy", "0.32em")
    .attr("fill", "#000")
    .attr("font-weight", "bold")
    .attr("text-anchor", "start")
    .text("Population");

var legend = g.append("g")
    .attr("font-family", "sans-serif")
    .attr("font-size", 10)
    .attr("text-anchor", "end")
  .selectAll("g")
  .data(keys.slice().reverse())
  .enter().append("g")
    .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

legend.append("rect")
    .attr("x", width - 19)
    .attr("width", 19)
    .attr("height", 19)
    .attr("fill", z);

legend.append("text")
    .attr("x", width - 24)
    .attr("y", 9.5)
    .attr("dy", "0.32em")
    .text(function(d) { return d; });


}
