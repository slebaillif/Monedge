import * as d3 from 'd3';
// import '../css/chart.css';

// const chart = d3.select('body')
//   .append('svg')
//   .attr('id', 'chart');


export function renderChart(data) {
  var svg = d3.select('div#chart').append('svg');

  var margin = {
    left: 30,
    top: 30,
    right: 30,
    bottom: 30
  };

  svg.attr('width', window.innerWidth);
  svg.attr('height', window.innerHeight);

  var width = window.innerWidth - margin.left - margin.right;
  var height = window.innerHeight - margin.top - margin.bottom;

  var   chart = svg.append('g')
    .attr('width', width)
    .attr('height', height)
    .attr('transform', `translate(${margin.left}, ${margin.top})`);
  chart.attr('width', window.innerWidth)
    .attr('height', window.innerHeight);

  const x = d3.scaleBand()
    .domain(data.map(d => d.letter))
    .rangeRound([50, window.innerWidth - 50])
    .padding(0.1);

  const y = d3.scaleLinear()
    .domain([0, d3.max(data, d => d.presses)])
    .range([window.innerHeight - 50, 0]);

  const xAxis = d3.axisBottom().scale(x);
  const yAxis = d3.axisLeft().scale(y);

  chart.append('g')
    .attr('class', 'axis')
    .attr('transform', `translate(0, ${window.innerHeight - 50})`)
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
     .attr('y', window.innerHeight - 50)
     .attr('width', x.bandwidth())
     .attr('height', 0)
       .transition()
       .delay((d, i) => i * 20)
       .duration(800)
       .attr('y', d => y(d.presses))
       .attr('height', d =>
           (window.innerHeight - 50) - y(d.presses));
}
