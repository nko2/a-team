Backbone = require ('backbone')

class Cue extends Backbone.Model
    initialize: ->

class CueCollection extends Backbone.Collection
    model: Cue

module.exports = { Cue, CueCollection }
