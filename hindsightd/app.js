#!/usr/bin/env node

var Firebase = require('firebase'),
// https   = require('https'),
// http   = require('http'),
request = require('request'),
cheerio  = require('cheerio'),
fbutil   = require('./fbutil'),
fburl = 'https://' + process.env.FB_NAME + '.firebaseio.com/',
express = require('express'),
htmlcarve = require("htmlcarve"),
cardi = require("cardi"),
app = express();

function get(url, cb){
  if (url.match(/^https/)) return https.get(url, cb);
  else return http.get(url, cb);
}


fbutil.auth(fburl, process.env.FB_TOKEN).done(function() {
  var  F = new Firebase(fburl);

  // app part

  app.use(express.logger());
  app.use(express.static(__dirname + '/../www'));
  app.use(express.bodyParser());

  app.get('/url/:url', function(req, res){
    console.log("URL: " + req.params.url);

    cardi.fromUrl(req.params.url, function (error, card) {
      console.log(card);
      if (!error){

        res.send(JSON.stringify({
          url: req.params.url,
          title: card.title,
          img: card.image
        }));

      } else {
        request({
          url: req.params.url,
          headers: {
            'User-Agent': 'facebookexternalhit/1.1 (+https://www.facebook.com/externalhit_uatext.php)'
          }
        }, function(error, response, body) {
          console.log("Got response: " + response.statusCode);
          response.setEncoding('utf8');
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
        }).on('error', function(e) {
          console.log("Got error: " + e.message);
        });

      }
    });
    // htmlcarve.fromUrl(req.params.url, function(error, data){
    //   if (!error){
    //     console.log(JSON.stringify(data));
    //
    //   } else {
    //
    //
    //
    //   }
    // });
  });

  var port = process.env.PORT || 5000;
  app.listen(port, function() { console.log("Listening on " + port); });
});
