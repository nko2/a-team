Backbone = require("backbone")
{ Cue, CueCollection } = require('./cue')

WHITELIST = ["author", "guests", "homepage", "episode", "series", "location", "date"]

class Podcast extends Backbone.Model
    initialize: ->
        @set cues: new CueCollection()
        #socket.of('/podcast').on 'push', (o) =>
        #    console.log "got pushed", o
    #
    fetch: ->
        socket.emit 'get', @get('podurl')

class PodcastCollection extends Backbone.Collection
    model: Podcast
    url: "/podcast"

    initialize: (socket=null) ->
        if socket
            @socket_io = socket.of("/podcast")
            @socket_io.on "send", (data) =>
                console.log("get data", data)


@Podcast = Podcast
@PodcastCollection = PodcastCollection

module.exports = { Podcast, PodcastCollection, WHITELIST }

