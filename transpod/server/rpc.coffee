{ ServerPodcast, ServerPodcastCollection } = require('./model/podcast')
url = require('url')
check = require('validator').check


console.log(ServerPodcast, ServerPodcastCollection)

# ♥
podcastListeners = {}

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
        user.onPush (obj) ->
            socket.emit 'push', obj

        socket.on 'list', (start, stop) ->
            console.log("list podcasts")

        socket.on 'get', (url) ->
            console.log("get podcast url:", url)
            user.get url

        socket.on 'addCue', (obj) ->
            user.addCue obj

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
                if err and err.error == 'not_found'
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

        socket.on 'addCue', (cue) ->
            podcast_collections.get_for_url url, (err, obj) =>
                console.log("got podcast, hurray", err, "end")
                console.log("obj", obj)
                unless err
                    socket.emit 'push', obj.toJSON()


module.exports = rpc_handler

