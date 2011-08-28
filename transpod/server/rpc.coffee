{ ServerPodcast, ServerPodcastCollection, TYPES } = require('./model/podcast')
{ WHITELIST } = require('../app/models/podcast')
{ guid } = require('../app/models/cue')
url = require('url')
check = require('validator').check
_ = require('underscore')


podcast_collections = new ServerPodcastCollection()

podcastListeners = {}
# push to all podcast listeners
pushAll = (url, obj) ->
    if podcastListeners[url]
        for socket in podcastListeners[url]
            try
                socket.emit 'push', obj
            catch e
                console.error "Error pushing: #{e.stack or e}"
        console.log "pushed to #{podcastListeners[url].length} listeners for #{url}"
    else
        console.warn "no one to push for #{url}"

rpc_handler = (io) ->
    io.of("/foo").on 'connection', (socket) ->
        console.log 'client connection', socket

        socket.on 'list', (start, stop) ->
            console.log("list podcasts")

        socket.on 'get', (url) ->
            console.log("get podcast url:", url)
            unless podcastListeners[url]
                podcastListeners[url] = []
            podcastListeners[url].push socket
            socket.on 'disconnect', ->
                podcastListeners[url] = podcastListeners[url].filter (socket1) ->
                    socket isnt socket1
                if podcastListeners[url].length < 1
                    delete podcastListeners[url]

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
                    npodcast = new ServerPodcast(podurl:url, status:"queued")
                    console.log("n podcast", npodcast)
                    npodcast.save (err, obj) =>
                        console.log("saved", err, obj)
                        # FIXME jobserver
                        npodcast.check (err, res) ->
                            console.log("check done", err, res)
                        npodcast.bind 'change', ->
                            pushAll url
                    #socket.emit 'send', npodcast.toJSON()
                else
                    console.log("push")
                    console.log("run check", obj)
                    obj.check (ok) =>
                        console.log("check ok")
                    pushCues = (key) ->
                        cues = obj.get(key)
                        a = {}
                        a[key] = null
                        obj.set a
                        for own cueId, cue of cues
                            cue.podurl = url
                            cue.type = key
                            socket.emit 'push', cue
                    pushCues 'chapter'
                    pushCues 'comment'
                    pushCues 'note'
                    pushCues 'transcript'
                    pushAll url, obj.toJSON()
        socket.on 'setValues', (data) ->
            url = data.podurl
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
                    pushAll url nobj.toJSON()



        socket.on 'addCue', (data) ->
            console.log(data)
            url = data.podurl
            cue = data.cue
            podcast_collections.get_for_url url, (err, obj) =>
                if not obj
                    return
                if not cue.type or not cue.type in TYPES
                    return

                typename = cue.type
                cur = obj.get(typename)
                if not cur or _.isObject(cur)
                    cur = {}
                if not cue.uid
                    cue.uid = guid()
                nid = cue.uid
                cur[nid] = cue
                vars = {}
                vars[typename] = cur
                obj.set(vars)
                obj.save()

                unless err
                    pushAll url, obj.toJSON()
                obj.save()


module.exports = rpc_handler

