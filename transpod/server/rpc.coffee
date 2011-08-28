{ ServerPodcast, ServerPodcastCollection, TYPES } = require('./model/podcast')
{ WHITELIST } = require('../app/models/podcast')
{ guid } = require('../app/models/cue')
url = require('url')
check = require('validator').check


console.log(ServerPodcast, ServerPodcastCollection)

# ♥
podcastListeners = {}
podcast_collections = new ServerPodcastCollection

class User
    constructor: ->
        @myUrls = []

    push: (obj) ->
        if @onPush
            @onPush obj

    shutdown: ->
        # Unsubscribe
        for url in @myUrls
            podcastListeners[url] =
                podcastListeners[url].filter (user) =>
                    user isnt @
            if podcastListeners[url].length < 0
                delete podcastListeners[url]

    get: (url) ->
        # Subscribe
        unless podcastListeners[url]?
            podcastListeners[url] = []
        podcastListeners[url].push @

        # Fetch

    addCue: (obj) ->

rpc_handler = (io) ->
    io.of('/podcast').on 'connection', (socket) ->
        user = new User()
        user.onPush = (obj) ->
            socket.emit 'push', obj

        socket.on 'list', (start, stop) ->
            console.log("list podcasts")

        socket.on 'get', (url) ->
            console.log("get podcast url:", url)
            user.get url

            try
                url = url.url
                console.log("rulr",url)
                check(url).isUrl()
            catch error
                console.log(error)
                return socket.emit("error", "not valid url")
            podcast_collections.get_for_url url, (err, obj) =>
                console.log("got podcast, hurray", err, "end")
                console.log("obj", obj)
                if err or not obj
                    console.log("new podcast", obj)
                    npodcast = new ServerPodcast podurl:url, status:"queued", bla:"blubb"
                    console.log("n podcast", npodcast)
                    npodcast.save (err, obj) =>
                        console.log("saved", err, obj)
                        # FIXME jobserver
                        npodcast.check (err, res) ->
                            console.log("check done", err, res)
                    #socket.emit 'send', npodcast.toJSON()
                else
                    console.log("push")
                    console.log("run check", obj)
                    obj.check (ok) =>
                        console.log("check ok")
                    socket.emit 'push', obj.toJSON()
        socket.on 'setValues', (data) ->
            url = data.url
            values = data.values
            if not url
                console.log("setValues failed, url missing")
                return
            podcast_collections.get_for_url url, (err, obj) ->
                if not obj
                    console.log("setValues failed, no podcast for url" + url)
                    return
                console.log("######################################################")
                console.log(values)
                for key, value of values
                    console.log("vvvv", key, value)
                    if key in WHITELIST
                        console.log("white")
                        vars = {}
                        vars[key] = value
                        obj.set(vars)
                obj.save (err, nobj)=>
                    socket.emit 'push', nobj.toJSON()



        socket.on 'addCue', (data) ->
            console.log(data)
            url = data.url
            cue = data.cue
            podcast_collections.get_for_url url, (err, obj) =>
                if not obj
                    return
                if not cue.type or not cue.type in TYPES
                    return

                typename = cue.type
                cur = obj.get(typename)
                if not cur
                    cur = {}
                if not cue.uid
                    cue.uid = guid()
                cur[cue.uid] = cue
                vars = {}
                vars[typename] = cue
                obj.set(vars)

                
                unless err
                    socket.emit 'push', obj.toJSON()
                obj.save()


module.exports = rpc_handler

