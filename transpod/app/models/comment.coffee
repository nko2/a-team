Cue = require './cue'
Backbone = require("backbone")

class @Comment extends Cue
    type: 'comment'

class @CommentCollection extends Backbone.Collection
    model: @Comment

module.exports = { @Comment, @CommentCollection }
