Cue = require("./cue")
Backbone = require("backbone")

class @Transcription extends Cue
    type: 'transcription'

class @TranscriptionCollection extends Backbone.Collection
    model: @Transcription

module.exports = { @Transcription, @TranscriptionCollection}
