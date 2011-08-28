Backbone = require ('backbone')

S4 = () ->
   return (((1+Math.random())*0x10000)|0).toString(16).substring(1)

guid = () ->
   return (S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4())

TYPES = ["chapter", "note", "transcription", "comment"]


class Cue extends Backbone.Model
    initialize: ->
        if not @get('uid')
            @set {'uid': guid()}

class CueCollection extends Backbone.Collection
    model: Cue

module.exports = { Cue, CueCollection, TYPES:TYPES, guid:guid }
