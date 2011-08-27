Backbone = require("backbone")
{ Chapter, ChapterCollection } = require('./chapter')
{ Note, NoteCollection } = require('./note')
{ Comment, CommentCollection } = require('./comment')
{ Transcription, TranscriptionCollection } = require('./chapter')

class Podcast extends Backbone.Model
  # required:
  # url
  # author
  defaults:
    "url":      null
    "author":   "unknown"
    "guests":   []

  initialize: ->
    # ...
    chapters = ChapterCollection
    notes = NoteCollection
    transcription = TranscriptionCollection
    comments = CommentCollection


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

