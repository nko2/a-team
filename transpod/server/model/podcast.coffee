Config = requir('../../config')
Podcast = require('../../app/models/podcast')
Path = require('Path')
Fs = require('fs')
Url = require('url')

class ServerPodcast extends Podcast
    filename: (typ) =>
        rv = Path.join(config.podcast_data, @id, typ)
        return rv
    check: (callback) =>
        fs.exists Path.join(config.podcast_data, @id, "done"), (exists) ->
            if exists
                return callback(null, true)

    download: () =>
        console.log("download file")

        options = Url.parse(@url).filter (name) -> return name in ['host', 'port', 'path']
        
        fetcher = http.get options, (res) =>
              console.log("Got response: " + res.statusCode)
        fetcher.on 'error', (err) ->
              console.log("Got error: " + err.message)


module.exports = ServerPodcast

