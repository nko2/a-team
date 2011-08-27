PORT = (process.env.VMC_APP_PORT || 3000)
HOST = (process.env.VCAP_APP_HOST || 'localhost')

config = require('../config')
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
MemoryStore = require('connect/lib/middleware/session/memory')
session_store = new MemoryStore()
cradle = require('cradle')
design = require('./design')

app = express.createServer()

#couch = require('backbone-couch')
#    host: '127.0.0.1',
#    port: '5984',
#    name: 'transpod'

config.db = db = new(cradle.Connection)({
    cache: true,
    raw: false
}).database('transpod')


#app = app.listen(PORT)
# Config
#app.set('views', __dirname + '/app/views')
#app.register('.html', require('ejs'))
#app.set('view engine', 'html')
design db, (err) ->
    app.configure () ->
        console.log(__dirname)
        app.use(express.logger())

        app.use(express.bodyParser())
        app.use(express.methodOverride())
        app.use(express.cookieParser())
        app.use(express.session({ store: session_store, secret: "im so secure" }))


        app.use(connect.static(__dirname + '/../public/'))
        app.use(express.errorHandler({dumpExceptions: true, showStack: true}))

        app.enable('log')
        console.log(rpc)

        public_path = path.join(__dirname, '..', 'public')
        requires = [
            'underscore'
            'backbone'
            'socket.io-client'
            path.join(__dirname, '..', 'app/requires.coffee')
            jquery:'jquery-browserify'
        ]
        console.log requires: requires
        javascript = browserify
            require: requires
            watch: true
            #fastmatch: true

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
        #couch.install (err) ->
        #  Backbone.sync = couch.sync

        #connect.router (app) ->
        Routes(app)

        app.use(app.router)

        app.listen(PORT)
        # setup socket.io
        io = sio.listen(app)
        io.enable('browser client etag')
        io.set('log level', 3)
        io.set('close timeout', 5000)
        io.set('resource', "/websocket")
        io.set('transports', ["xhr-polling", "htmlfile", "json-polling"]) #["websocket", "xhr-polling", "htmlfile", "json-polling"])
        io.set('heartbeat timeout': 60)
        #io.set('store', session_store)

        console.log(io)

        rpc(io)

        console.log('App started on port: ' + PORT)


module.exports = app
