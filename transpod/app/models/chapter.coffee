Cue = require './cue'
Backbone = require("backbone")

class @Chapter extends Cue
    type: 'chapter'

class @ChapterCollection extends Backbone.Collection
    model: @Chapter

module.exports = { @Chapter, @ChapterCollection }

