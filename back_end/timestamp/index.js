// index.js
// where your node app starts

// init project
var express = require('express');
var app = express();

// enable CORS (https://en.wikipedia.org/wiki/Cross-origin_resource_sharing)
// so that your API is remotely testable by FCC 
var cors = require('cors');
app.use(cors({ optionsSuccessStatus: 200 }));  // some legacy browsers choke on 204

// http://expressjs.com/en/starter/static-files.html
app.use(express.static('public'));

// http://expressjs.com/en/starter/basic-routing.html
app.get("/", function (req, res) {
  res.sendFile(__dirname + '/views/index.html');
});


// your first API endpoint... 
app.get("/api/hello", function (req, res) {
  res.json({ greeting: 'hello API' });
});

app.get('/api/:date?', (req, res, next) => {
  const unixRegex = /^-?(0|[1-9]\d{0,15})$/;

  if (req.params.date === undefined) {
    req.timestamp = new Date();
  } else if (unixRegex.test(req.params.date)) {
    req.timestamp = new Date(parseInt(req.params.date));    
  }
  else {
    req.timestamp = new Date(req.params.date);
  }

  if (req.timestamp.toString() === "Invalid Date") {
    return res.json({ error: "Invalid Date" });
  }
  else next()
}, (req, res) => {
  res.json({
    unix: new Date(req.timestamp).valueOf(),
    utc: new Date(req.timestamp).toUTCString()
  })
});

// Listen on port set in environment variable or default to 3000
var listener = app.listen(process.env.PORT || 3000, function () {
  console.log('Your app is listening on port ' + listener.address().port);
});
