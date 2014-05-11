#!/usr/bin/env node

var Firebase = require('firebase'),
// https   = require('https'),
// http   = require('http'),
request = require('request'),
cheerio  = require('cheerio'),
fbutil   = require('./fbutil'),
fburl = 'https://' + process.env.FB_NAME + '.firebaseio.com/',
express = require('express'),
app = express();

function get(url, cb){
  if (url.match(/^https/)) return https.get(url, cb);
  else return http.get(url, cb);
}


fbutil.auth(fburl, process.env.FB_TOKEN).done(function() {
  var  F = new Firebase(fburl);

  // app part

  app.use(express.logger());
  app.use(express.static(__dirname));
  app.use(express.bodyParser());

  app.get('/url/:url', function(req, res){
    console.log("URL: " + req.params.url);

    request({
      url: req.params.url,
      headers: {
        'User-Agent': 'facebookexternalhit/1.1 (+https://www.facebook.com/externalhit_uatext.php)'
      }
    }, function(error, response, body) {
      console.log("Got response: " + response.statusCode);
      response.setEncoding('utf8');
      var meta = {};

      // console.log('data:', chunk);
      $ = cheerio.load(body);
      $('meta').each(function () {
        x = this;
        var p = $(x).attr('property') || $(x).attr('name');
        if (p) meta[p] = $(x).attr('content');
      });

      console.log('Open Graph data', meta);
      // console.log(body);
      // first, try open graph

      var title = meta && (meta['og:title'] || meta['og:site_name']);
      if (title){
        res.send(JSON.stringify({
          url: req.params.url,
          title: title,
          img: meta['og:image']
        }));
      } else {
          // console.log("err:",err);
          // otherwise try scrapin

          var m = body.match(/<title[^>]*?>(.*)<\/title>/);
          var img = body.match(/<meta content="([^"]+)" property="og:image" \/>/);
          if (m){
            res.send(JSON.stringify({
              url: req.params.url,
              title: m[1],
              img: img && img[1]
            }));
          } else {
            console.log(body);
            res.send('error');
          }

      }



    }).on('error', function(e) {
      console.log("Got error: " + e.message);
    });

  });

  var port = process.env.PORT || 5000;
  app.listen(port, function() { console.log("Listening on " + port); });
});
