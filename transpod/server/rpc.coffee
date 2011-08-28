{ ServerPodcast, ServerPodcastCollection, TYPES } = require('./model/podcast')
{ WHITELIST } = require('../app/models/podcast')
{ guid } = require('../app/models/cue')
url = require('url')
check = require('validator').check


console.log(ServerPodcast, ServerPodcastCollection)
podcast_collections = new ServerPodcastCollection()


rpc_handler = (io) ->
    io.sockets.on 'connection', (socket) ->
        console.log 'client connection', socket

        socket.on 'list', (start, stop) ->
            console.log("list podcasts")

        socket.on 'get', (url) ->
            console.log("get podcast url:", url)

            try
                console.log("rulr",url)
                check(url).isUrl()
            catch error
                console.log(error)
                return socket.emit("error", "not valid url")
            podcast_collections.get_for_url url, (err, obj) =>
                console.log("got podcast, hurray", err, "end")
                console.log("obj", obj)
                if err or not obj
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
                    console.log("push")
                    console.log("run check", obj)
                    obj.check (ok) =>
                        console.log("check ok")
                    # TODO: push to all podcast listeners
                    socket.emit 'push', obj.toJSON()
        socket.on 'setValues', (data) ->
            url = data.url
            values = data.values
            if not url
                console.log("setValues failed, url missing")
                return
            podcast_collections.get_for_url url, (err, obj) ->
                if not obj
                    console.log("setValues failed, no podcast for url" + url)
                    return
                console.log("######################################################")
                console.log(values)
                for key, value of values
                    console.log("vvvv", key, value)
                    if key in WHITELIST
                        console.log("white")
                        vars = {}
                        vars[key] = value
                        obj.set(vars)
                        obj.save()
                obj.save (err, nobj)=>
                    # TODO: push to all podcast listeners
                    socket.emit 'push', nobj.toJSON()



        socket.on 'addCue', (data) ->
            console.log(data)
            url = data.url
            cue = data.cue
            podcast_collections.get_for_url url, (err, obj) =>
                if not obj
                    return
                if not cue.type or not cue.type in TYPES
                    return

                typename = cue.type
                cur = obj.get(typename)
                if not cur
                    cur = {}
                if not cue.uid
                    cue.uid = guid()
                cur[cue.uid] = cue
                vars = {}
                vars[typename] = cue
                obj.set(vars)
                obj.save()

                unless err
                    # TODO: push to all podcast listeners
                    socket.emit 'push', obj.toJSON()
                obj.save()


module.exports = rpc_handler

