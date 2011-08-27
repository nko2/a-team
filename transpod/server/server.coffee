PORT = (process.env.VMC_APP_PORT || 3000)
HOST = (process.env.VCAP_APP_HOST || 'localhost')

fs = require('fs')
express = require('express')
app = express.createServer()
colors = require('colors')

# Config
app.set('views', __dirname + '/app/views')
#app.register('.html', require('ejs'))
app.set('view engine', 'html')

app.configure () ->
    app.use(express.bodyParser())
    app.use(express.methodOverride())
    app.use(express.cookieParser())
    app.use(express.static(__dirname + '/public'))
    app.use(app.router)
    app.use(express.errorHandler({dumpExceptions: true, showStack: true}))


# Resources
###
bootResources(app) ->
  fs.readdir(__dirname + '/app/resource', (err, files){
    if (err) { throw err; }
    files.forEach((file) ->
      if ((file.indexOf("~") > -1) || (file.indexOf(".svn") > -1))
        return;
      }

      var name = file.replace('.js', '')
        , Res = require('./app/resource/' + name);

      if (typeof Res !== 'function') {
        return; // since this isn't a resource
      }

      if (typeof Res.prototype.route !== 'function') {
        return; // since this isn't a resource
      }

      var r = new Res();
      r.route(app);
    });
  });
}
bootResources(app)
###

if !module.parent
    app.listen(PORT)
    console.log('App started on port: ' + PORT)


module.exports = app
