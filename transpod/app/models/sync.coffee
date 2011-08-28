{ Podcast } = require('./podcast')
{ Cue } = require('./cue')

module.exports = (method, model, options) ->
    if method is 'read' and model.constructor is Podcast
        socket.emit 'get', model.get('url')
    if method is 'create' and model.constructor is Cue
        socket.emit 'addCue',
            url: model.get('podcast')
            cue: model.toJSON()
