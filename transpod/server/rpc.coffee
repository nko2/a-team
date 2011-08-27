Podcast = require('./model/podcast')

rpc_handler = (socket) ->
    socket.on 'podcast/list', (start, stop) ->
        console.log("list podcasts")
        
module.exports = rpc_handler

