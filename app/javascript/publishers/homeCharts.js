// TODO: import only the aspects of d3 that are being used
import * as d3 from "d3";

function getUrlCleanly(url) {
  if (url.startsWith("twitch#channel:") || url.startsWith("twitch#author:")) {
    return "https://twitch.tv/" + url.split(":")[1];
  } else if (url.startsWith("youtube#channel:")) {
    return "https://youtube.com/channel/" + url.split(":")[1];
  } else {
    return "https://" + url;
  }
}

function displayUrl(url) {
  if (url.startsWith("twitch#channel:") || url.startsWith("twitch#author:")) {
    return "Twitch.tv: " + url.split(":")[1];
  } else if (url.startsWith("youtube#channel:")) {
    return "Your YouTube Channel";
  } else {
    return url;
  }
}

/**
  x: x-coordinate
  y: y-coordinate
  w: width
  h: height
  r: corner radius
  tl: top_left rounded?
  tr: top_right rounded?
  bl: bottom_left rounded?
  br: bottom_right rounded?
*/

function roundedRect(x, y, w, h, r, tl, tr, bl, br) {
  let retval;
  retval  = "M" + (x + r) + "," + y;
  retval += "h" + (w - 2*r);
  if (tr) { retval += "a" + r + "," + r + " 0 0 1 " + r + "," + r; }
  else { retval += "h" + r; retval += "v" + r; }
  retval += "v" + (h - 2*r);
  if (br) { retval += "a" + r + "," + r + " 0 0 1 " + -r + "," + r; }
  else { retval += "v" + r; retval += "h" + -r; }
  retval += "h" + (2*r - w);
  if (bl) { retval += "a" + r + "," + r + " 0 0 1 " + -r + "," + -r; }
  else { retval += "h" + -r; retval += "v" + -r; }
  retval += "v" + (2*r - h);
  if (tl) { retval += "a" + r + "," + r + " 0 0 1 " + r + "," + -r; }
  else { retval += "v" + -r; retval += "h" + r; }
  retval += "z";
  return retval;
}

/**
 renderDepositsBarChart example usage:

 ```
 let deposits = [
 {
   date: '7/30',
   'AmazingBlog on YouTube': 63,
   'amazingblog.com': 200,
   'Amazon.com': 50
 },
 {
   date: '8/30',
   'AmazingBlog on YouTube': 150,
   'amazingblog.com': 100,
   'Amazon.com': 350
 },
 {
   date: '9/30',
   'AmazingBlog on YouTube': 63,
   'amazingblog.com': 200,
   'Amazon.com': 50
 },
 {
   date: '10/31',
   'AmazingBlog on YouTube': 150,
   'amazingblog.com': 100,
   'Amazon.com': 350
 },
 {
   date: '11/30',
   'amazingblog.com': 50,
   'Amazon.com': 200
 }
 ];

 let channels = ['AmazingBlog on YouTube', 'amazingblog.com', 'Amazon.com'];
 let colors = ['#e79895', '#5edaea', '#1db899'];

 renderDepositsBarChart({
    parentSelector: '#monthly_statements_chart',
    deposits,
    channels,
    colors,
    currency: 'USD',
    currencyConversion: 0.25
  });

 ```
 */
export function renderDepositsBarChart(options) {
  let {
    parentSelector,
    deposits,
    channels,
    colors,
    currency,
    currencyConversion,
    width,
    height,
    margin
  } = options;

  const MONTH_NAMES = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

  let data = deposits.map(d => {
    let total = 0;
    let deposit = {
      date: MONTH_NAMES[parseInt(d.date.split("-")[1])]
    };
    for (let i = 0; i < channels.length; i++) {
      let channel = channels[i];
      let amount = d[channel] || 0;
      amount *= currencyConversion;
      total += amount;
      deposit[channel] = amount;
    }
    deposit.total = total;
    return deposit;
  });

  margin = margin || { top: 50, right: 50, bottom: 50, left: 50 };
  width = width || data.length * 35;
  height = height || 180;

  let keys = channels;
  let verticalTicks = 3;

  let svg = d3.select(parentSelector)
    .append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top + margin.bottom)
    .append('g')
    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

  let x = d3.scaleBand()
    .rangeRound([0, width])
    .padding(0.4)
    .paddingInner(0.4)
    .align(0.4);

  let y = d3.scaleLinear()
    .rangeRound([height, 0]);

  let z = d3.scaleOrdinal()
    .range(colors);

  let maxY = d3.max(data, (d) => d.total);
  var barCount = 0;
  var topBarLimit = data.length * (channels.length - 1);

  x.domain(data.map((d) => d.date));
  y.domain([0, maxY]);
  z.domain(keys);

  svg.append('g')
    .attr('class', 'x-axis')
    .attr('transform', 'translate(0, ' + height + ')')
    .call(d3.axisBottom(x).tickSize(8));

  svg.append('g')
    .attr('class', 'y-axis')
    .call(d3.axisLeft(y).ticks(verticalTicks).tickSize(-width))
    .append('text')
    .attr('class', 'y-units')
    .attr("font-weight", "bold")
    .attr('text-anchor', 'end')
    .attr('x', -12)
    .attr('y', -20)
    .text(currency);

  svg.append("g")
    .selectAll("g")
      .data(d3.stack().keys(keys)(data))
      .enter().append("g")
      .attr("fill", function(d) { return z(d.key); })
      .selectAll("rect")
        .data(function(d) { return d; })
        .enter().append("path")
          .attr("d", function(d, i, q) {
            barCount += 1;
            var curveTopBar = barCount > topBarLimit;
            return roundedRect(x(d.data.date), y(d[1]), x.bandwidth(), y(d[0]) - y(d[1]), 8, curveTopBar, curveTopBar, false, false);
          });
}

/**
 renderContributionsDonutChart example usage:

 ```
 let amounts = {
    'AmazingBlog on YouTube': 63,
    'amazingblog.com': 200,
    'Amazon.com': 50
  };
 let channels = ['AmazingBlog on YouTube', 'amazingblog.com', 'Amazon.com'];
 let colors = ['#e79895', '#5edaea', '#1db899'];

 renderContributionsDonutChart({
    parentSelector: '#contributions_chart',
    amounts,
    channels,
    colors,
    currency: 'BAT',
    currencyConversion: 1.0,
    altCurrency: 'USD',
    altCurrencyConversion: 0.25
  });

 ```
 */
export function renderContributionsDonutChart(options) {
  let {
    parentSelector,
    amounts,
    channels,
    colors,
    currency,
    currencyConversion,
    altCurrency,
    altCurrencyConversion,
    width,
    height,
    margin,
    donutWidth
  } = options;

  margin = margin || { top: 0, right: 100, bottom: 0, left: 0 };
  width = width || 250;
  height = height || 250;
  donutWidth = donutWidth || 40;

  let marginRight = 100;
  let radius = Math.min(width , height) / 2;
  let legendRadius = 10;
  let legendSpacing = 4;
  let padAngle = 0.02;

  let data = [];
  for (let i = 0; i < channels.length; i++) {
    let channel = channels[i];
    let amount = amounts[channel] || 0;
    amount *= currencyConversion;
    let color = colors[i];

    if (amount !== 0) {
      data.push({ channel, amount, color });
    }
  }

  data.sort((a, b) => a.amount > b.amount);

  let total = 0;
  data.forEach(d => { total += d.amount; });

  let svg = d3.select(parentSelector)
    .append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top + margin.bottom)
    .append('g')
    .attr('transform', 'translate(' + (width / 2) +
      ',' + (height / 2) + ')');

  svg.append('text')
    .attr('text-anchor', 'middle')
    .attr('y', 0)
    .attr('class', 'total')
    .text(total);

  if (altCurrency) {
    let altTotal = total / currencyConversion * altCurrencyConversion;

    svg.append('text')
      .attr('text-anchor', 'middle')
      .attr('y', 25)
      .attr('class', 'alt-total')
      .text(`~ ${altTotal} ${altCurrency}`);
  }

  let arc = d3.arc()
    .innerRadius(radius - donutWidth)
    .outerRadius(radius)
    .padAngle(padAngle);

  let pie = d3.pie()
    .value(d => d.amount)
    .sort(null);

  let path = svg.selectAll('path')
    .data(pie(data))
    .enter()
    .append('path')
    .attr('d', arc)
    .attr('fill', (d, i) => d.data.color);

  data.reverse();

  let legend = svg.selectAll('.legend')
    .data(data)
    .enter()
    .append('g')
    .attr('class', 'legend')
    .attr('transform', function(d, i) {
      let height = legendRadius * 2.5 + legendSpacing;
      let offset = height * data.length / 2;
      let horz = radius + (4 * legendRadius);
      let vert = i * height - offset;
      return 'translate(' + horz + ',' + vert + ')';
    });

  legend.append('circle')
    .attr('r', legendRadius)
    .style('fill', (d, i) => d.color)
    .style('stroke', (d, i) => d.color);

  legend
    .append("svg:a").attr("href", function(d){ return getUrlCleanly(d.channel) })
    .append('text')
    .attr('x', legendRadius * 1.5 + legendSpacing)
    .attr('y', legendRadius * 0.7 - legendSpacing)
    .text(d => displayUrl(d.channel));
}

/**
 * The following are example usages of `renderContributionsDonutChart` and `renderDepositsBarChart`.
 * These should only be invoked on the home page when it's opened with the `charts=true` query param.
 *
 * This should be replaced with dynamic code in home.js that renders charts after querying eyeshade for deposit data.
 */

document.addEventListener('eyeshade-balance-received', function() {
  if (document.querySelectorAll('body[data-action="home"]').length === 0 ||
      !document.getElementById('contributions_chart')) {
    return;
  }

  let channel_balances = JSON.parse(document.getElementById('channel_balances').getAttribute('data-channel-balances-json'));

//  let channels = ['AmazingBlog on YouTube', 'amazingblog.com', 'Amazon.com'];
  let channels = Object.keys(channel_balances);

  let colors = ['#e79895', '#5edaea', '#1db899', '#442299', '#ff6644', '#11aabb', '#ff9933', '#22ccaa', '#feae2d', '#d0c310', '#aacc22', '#69d025', '#4444dd']
  let amounts = {};

  for (var k in channel_balances) {
    amounts[k] = '' + channel_balances[k]["amount"];
  }

  renderContributionsDonutChart({
    parentSelector: '#contributions_chart',
    channels,
    colors,
    amounts: amounts,
    currency: 'BAT',
    currencyConversion: 1.0,
    altCurrency: 'USD',
    altCurrencyConversion: 0.25,
    width: 200,
    height: 200,
    margin: { left: 0, right: 250, top: 0, bottom: 0},
    donutWidth: 30
  });
});

document.addEventListener('eyeshade-statement-received', function() {
  if (document.querySelectorAll('body[data-action="home"]').length === 0 ||
      !document.getElementById('contributions_chart')) {
    return;
  }

  let allStatementBalances = JSON.parse(document.getElementById('dashboard_monthly_statement_balances_chart').getAttribute('data-monthly-statement-json'));

  let channels = [];
  let deposits = [];
  let deposit = {};
  allStatementBalances.forEach(function(monthlyStatementBalances) {
    monthlyStatementBalances['channel_statements'].forEach(
      function(channelStatement) {
        channels.push(channelStatement['publisher']);
        deposit['date'] = monthlyStatementBalances['month'],
        deposit[channelStatement['publisher']] = channelStatement['amount'] || channelStatement['BAT']
      });
    deposits.push(deposit);
    deposit = {};
  });

  // Example: channels = ['AmazingBlog on YouTube', 'amazingblog.com', 'Amazon.com'];
  channels = [...new Set(channels)]

  let colors = ['#e79895', '#5edaea', '#1db899', '#442299', '#ff6644', '#11aabb', '#ff9933', '#22ccaa', '#feae2d', '#d0c310', '#aacc22', '#69d025', '#4444dd']

  renderDepositsBarChart({
    parentSelector: '#monthly_statements_chart',
    channels,
    colors,
    /*
    deposits: [
      {
        date: '7/30',
        'AmazingBlog on YouTube': 63,
        'amazingblog.com': 200,
        'Amazon.com': 50
      },
      {
        date: '8/30',
        'AmazingBlog on YouTube': 150,
        'amazingblog.com': 100,
        'Amazon.com': 350
      },
      {
        date: '9/30',
        'AmazingBlog on YouTube': 63,
        'amazingblog.com': 200,
        'Amazon.com': 50
      },
      {
        date: '10/31',
        'AmazingBlog on YouTube': 150,
        'amazingblog.com': 100,
        'Amazon.com': 350
      },
      {
        date: '11/30',
        'amazingblog.com': 50,
        'Amazon.com': 200
      }
    ],
    */
    deposits: deposits,
    // (Albert Wang): We'll change this later, it's possible that dollar amounts can't be determined due to
    // volatility of crypto to fiat.
    currency: 'BAT',
    currencyConversion: 1,
    /*
    currency: 'USD',
    currencyConversion: 0.25,
    */
    height: 160,
    margin: { left: 50, right: 50, top: 30, bottom: 30},
  });
});
