Backbone = require("backbone")

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


class PodcastCollection extends Backbone.Collection
    model: Podcast

@Podcast = Podcast
@PodcastCollection = PodcastCollection

module.exports = { Podcast, PodcastCollection }

