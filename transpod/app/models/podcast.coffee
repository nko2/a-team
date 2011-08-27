Backbone = require("backbone")

class Podcast extends Backbone.Model
  # required:
  # url
  # author
  defaults:
    "url":      None
    "author":   "unknown"
    "guests":   []

  initialize: ->
    # ...

@Podcast = Podcast
