Config = require('../../config')
{ Podcast, PodcastCollection }  = require('../../app/models/podcast')
Path = require('path')
fs = require('fs')
Url = require('url')
query = require('querystring')
_ = require('underscore')
{ Downloader } = require('../downloader')

console.log("podcast", Podcast, PodcastCollection)

safe_url = (url) ->
    return query.escape(url).replace(/\%/g,"_")

class ServerPodcast extends Podcast
    filename: (typ) =>
        rv = Path.join(Config.podcast_data, @id, typ)
        return rv
    check: (callback) =>
        Path.exists Path.join(Config.podcast_data, @id, "done"), (exists) =>
            if exists
                return callback(null, true)
            else
                @download callback

    download: (callback) =>
        console.log("download file")

        nd = new Downloader
        console.log(Config.podcast_data)
        nd.setOutput(Config.podcast_data)
        nd.download(@get("podurl")) #Url.parse(@get("podurl")).href)

        #options = Url.parse(@get("podurl"))
        #console.log(options)
        #o = { host:options.host, port:options.port, path:options.pathname }
        #o["type"] = "tcp6"
        #console.log("options", o)
        #fetcher = http.get o, (res) =>
        #      console.log("Got response: " + res.statusCode, res)
        #      callback(null, null)
        nd.on 'success', =>
            @set "download":true
            @save()
            callback(null, this)
        nd.on 'failed', (err) =>
            console.log("Got error: " + err.message)
            @set "last_error": err
            @save()
            callback(err, null)
        nd.on 'progress', (progress) =>
            if parseInt(progress)%10 == 0
                @set "progress": progress
                @save()
                

    _id: () =>
        console.log "_id", safe_url(@get("podurl"))
        rv =  "podcast_" + safe_url(@get("podurl"))
        console.log(rv)
        return rv

    save: (callback) =>
        console.log("save model")
        if not @get("podurl")
            throw new Error("podurl is required")
        changed = @changedAttributes()
        console.log("changed", changed)
        data = @toJSON()
        data["_id"] = @_id()
        data["type"] = "podcast"
        is_new = not data["_rev"]
        data["id"] = data["name"] = @get("podurl")
        console.log("data", data, @_id())
        console.log "ServerPodcast", @
        if is_new
            Config.db.save [data], data, (err, res) =>
                console.log("saved error:", err, res)
                if res
                    @set "_rev":(res.rev or "xxx")
                callback(err, res) if callback
        else
            console.log("merge")
            #delete data["_id"]
            #delete data["id"]
            console.log(data)
            # data["_rev"]
            ndata = { _id: data._id }
            ndata["progress"] = data.progress
            Config.db.merge ndata, (err, res) =>
                console.log("merge saved error:", err, res)
                if res
                    @set "_rev":(res.rev or "xxx")
                callback(err, this) if callback

class ServerPodcastCollection extends PodcastCollection
    get_for_url: (url, callback) ->
        _id = "podcast_" + safe_url(url)
        console.log("request", _id)
        Config.db.get [_id], (err, doc) =>
            console.log("err", err, doc)
            if err or not doc or doc[0].error
                 return callback err, null
            pod = new ServerPodcast doc[0].doc
            callback err, pod

module.exports = { ServerPodcast, ServerPodcastCollection }

