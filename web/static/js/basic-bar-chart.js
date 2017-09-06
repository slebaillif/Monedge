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
  .domain(['clothing', 'energy'])
  .rangeRound([50, window.innerWidth - 250])
  .padding(0.1);

  const y = d3.scaleLinear()
  .domain([0, d3.max(d => d.total)])
  .range([window.innerHeight - 150, 0]);

  const z = d3.scaleOrdinal()
  .domain(d => d.month)
  .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);

  var stack = d3.stack();

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

  stack.keys([1,2]);

  console.log(data);

  chart.selectAll('rect')
  .data(stack(data))
  .attr("fill", function(d) { return z(d.month); })
  .enter()
  .append('rect')
  .attr('class', 'bar')
  .attr('x', d => x(d.category))
  .attr('width', x.bandwidth())
  .attr('y', d => y(d.amount))
  .attr('height', d =>  y(d.total) - y(d.amount));
}
