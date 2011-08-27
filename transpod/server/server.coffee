PORT = (process.env.VMC_APP_PORT || 3000)
HOST = (process.env.VCAP_APP_HOST || 'localhost')

fs = require('fs')
express = require('express')
eyes = require('eyes')
colors = require('colors')
connect = require('connect')
Backbone = require('backbone')
Routes = require('./routes')
sio = require('socket.io')
rpc = require('./rpc')
browserify = require('browserify')
path = require('path')
coffee = require('coffee-script')

app = express.createServer()

couch = require('backbone-couch')
    host: '127.0.0.1',
    port: '5984',
    name: 'transpod'



# Config
#app.set('views', __dirname + '/app/views')
#app.register('.html', require('ejs'))
#app.set('view engine', 'html')

app.configure () ->
    console.log(__dirname)
    app.use(express.logger())
    app.use(express.bodyParser())
    app.use(express.methodOverride())
    app.use(express.cookieParser())

    app.use(connect.static(__dirname + '/../public/'))
    app.use(express.errorHandler({dumpExceptions: true, showStack: true}))

    app.enable('log')
    console.log(rpc)

    public_path = path.join(__dirname, '..', 'public')
    requires = [
        'underscore'
        'backbone'
        path.join(__dirname, '..', 'app/requires.coffee')
        jquery:'jquery-browserify'
    ]
    console.log requires: requires
    javascript = browserify
        require: requires
        fastmatch: true

    backbone = path.join(__dirname, '..', '..', "node_modules", "backbone", "backbone.js")
    javascript.register 'pre', ->
        @files[backbone].body = @files[backbone].body.replace(
            "var module = { exports : {} };",
            "var module = { exports : {_:window._, jQuery:window.$} };")

    javascript.register '.coffee',  (body) ->
         return coffee.compile(body)
    app.use javascript


    # Create database, push default design documents to it and
    # assign sync method to Backbone.
    couch.install (err) ->
      Backbone.sync = couch.sync

    #connect.router (app) ->
    Routes(app)

    app.use(app.router)
    
    app.listen(PORT)
    
    # setup socket.io
    io = sio.listen(app)
    
    app.on 'connection', rpc
    console.log('App started on port: ' + PORT)


module.exports = app
