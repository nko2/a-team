Backbone = require("backbone")
{ Cue, CueCollection } = require('./cue')

class Podcast extends Backbone.Model
    defaults:
        url: null
        author: "unknown"
        guests: []

    initialize: ->
        @set cues: new CueCollection()
        socket.of('/podcast').on 'push', (o) =>
            console.log "got pushed", o

class PodcastCollection extends Backbone.Collection
    model: Podcast
    url: "/podcast"

    initialize: (socket=null) ->
        if socket
            @socket_io = socket.of("/podcast")
            @socket_io.on "send", (data) =>
                console.log("get data", data)


    get_url: (url) =>
        @socket_io.emit("get", {"url": url})

@Podcast = Podcast
@PodcastCollection = PodcastCollection

module.exports = { Podcast, PodcastCollection }

