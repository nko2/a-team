Config = require('../../config')
{ Podcast, PodcastCollection }  = require('../../app/models/podcast')
Path = require('path')
fs = require('fs')
Url = require('url')
query = require('querystring')

console.log("podcast", Podcast, PodcastCollection)

class ServerPodcast extends Podcast
    filename: (typ) =>
        rv = Path.join(Config.podcast_data, @id, typ)
        return rv
    check: (callback) =>
        Path.exists Path.join(Config.podcast_data, @id, "done"), (exists) ->
            if exists
                return callback(null, true)
    download: () =>
        console.log("download file")

        options = Url.parse(@url).filter (name) -> return name in ['host', 'port', 'path']

        fetcher = http.get options, (res) =>
              console.log("Got response: " + res.statusCode)
        fetcher.on 'error', (err) ->
              console.log("Got error: " + err.message)

    _id: () =>
        console.log "_id", query.escape(@get("podurl"))
        rv =  "podcast/" + query.escape(@get("podurl"))
        console.log(rv)
        return rv

    save: (callback) =>
        console.log("save model")
        data = @toJSON()
        data["_id"] = @_id()
        data["type"] = "podcast"
        data["id"] = data["name"] = @get("podurl")
        console.log("data", data, @_id())
        Config.db.save [data], data, (err, res) ->
            console.log("saved error:", err, res)
            callback(err, res)

class ServerPodcastCollection extends PodcastCollection
    get_for_url: (url, callback) ->
        _id = "podcast/" + query.escape(url)
        console.log("request", _id)
        Config.db.get [_id], (err, doc) =>
            console.log("err", err, doc)
            if err or not doc or not doc.length
                 return callback err, null
            pod = new ServerPodcast doc[0].doc
            callback err, pod

module.exports = { ServerPodcast, ServerPodcastCollection }

