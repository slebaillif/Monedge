// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html";
import MainView from './main';
import * as bar from './basic-bar-chart';
// import PieSeb from './pie';
import d3 from "d3"

function handlDOMContentLoaded(){
  const view = new MainView();
  view.mount();
  window.currentView = view;
}

function handlDOMContentUnload(){
  window.currentView.unmount();
}

window.addEventListener('DOMContentLoaded', handlDOMContentLoaded, false);
window.addEventListener('unload', handlDOMContentUnload, false);

// export var App = {
//   run: function(data){
//     var p = new PieSeb();
//     p.drawPie(data);
//   }
// }

export var App2 = {
  barChart: function(data)  {bar.renderChart(data);},
  stackedBarChart: function(data)  {bar.renderStackedChart(data);}
}


// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
