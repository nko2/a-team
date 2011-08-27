Cue = require("./cue")
Backbone = require("backbone")

class @Note extends Cue
    type: 'note'

class @NoteCollection extends Backbone.Collection
    model: @Note

module.exports = { @Note, @NoteCollection }
