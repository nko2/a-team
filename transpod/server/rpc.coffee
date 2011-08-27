{ ServerPodcast, ServerPodcastCollection } = require('./model/podcast')
url = require('url')
check = require('validator').check


console.log(ServerPodcast, ServerPodcastCollection)


rpc_handler = (io) ->
    io.of('/podcast').on 'connection', (socket) ->
        podcast_collections = new ServerPodcastCollection
        #pod
        console.log("!!!!!!!         got connection !!!!!!")
        socket.on 'list', (start, stop) ->
            console.log("list podcasts")
            
        socket.on 'get', (url) ->
            console.log("get podcast url:", url)
            try
                url = url.url
                console.log("rulr",url)
                check(url).isUrl()
            catch error
                console.log(error)
                return socket.emit("error", "not valid url")
            podcast_collections.get_for_url url, (err, obj) =>
                console.log("got podcast, hurray", err, "end")
                console.log("obj", obj)
                if err and err.error == 'not_found'
                    console.log("new podcast", obj)
                    npodcast = new ServerPodcast podurl:url, status:"queued", bla:"blubb"
                    console.log("n podcast", npodcast)
                    npodcast.save (err, obj) =>
                        console.log("saved", err, obj)
                        # FIXME jobserver
                        npodcast.check (err, res) ->
                            console.log("check done", err, res)
                    #socket.emit 'send', npodcast.toJSON()
                else
                    socket.emit 'push', obj.toJSON()
                    obj.check (ok) =>
                        console.log("check ok")

module.exports = rpc_handler

