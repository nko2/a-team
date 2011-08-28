Config = require('../../config')
{ Podcast, PodcastCollection }  = require('../../app/models/podcast')
{ Cue, CueCollection, TYPES } = require('../../app/models/cue')
{ EventEmitter } = require('events')
Path = require('path')
fs = require('fs')
Url = require('url')
query = require('querystring')
_ = require('underscore')
{ Downloader } = require('../downloader')
spawn = require('child_process').spawn
Waveform = require('../waveform_render')


safe_url = (url) ->
    return query.escape(url).replace(/\%/g,"_")



class ServerCue extends Cue


class Converter extends EventEmitter
    constructor: (@sourcefile, @outpath) ->

    run: (callback) =>
        child = spawn("./transcoder/transcode.py", [@sourcefile, @outpath])

        child.stdout.on 'data', (data) =>
            data = data.toString('ascii')
            lines = data.split("\n")
            for line in lines
                @emit("sample", Number(line))
        child.stderr.on 'data', (data) ->
            console.log data

        child.on 'exit', (code) =>
            callback(code, this)



class ServerPodcast extends Podcast
    filename: (typ) =>
        rv = Path.join(Config.podcast_data, @id, typ)
        return rv

    generate_filename: (suffix) =>
        return Path.join(Config.static_dir, @_id, "audio" + suffix or "")

    check: (callback) =>
        console.log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
        console.log(@generate_filename("mp3"))
        checked = (exists) =>
            
            if not exists or @get("download") != "done"
                console.log("path missing, downloading")
                @download (err) =>
                    if not err
                        conv = new Converter(@get("sourcefile"))
                        render = new Waveform.SeriesRenderer()
                        render.on 'image', (png, start, stop) ->
                            fs.writeFileSync "/tmp/transpod-#{start}-#{stop}.png", png
                        conv.on "sample", (value) =>
                            render.write(value)
                            true

                        conv.run (err, n) =>
                            # after convert
                            callback(err, true)
            else
                return callback(null, true)
        if not @get("source_file")
            checked(false)
        else
            Path.exists @get("source_file"), checked

    download: (callback) =>
        console.log("download file")
        @set(status:"download")

        nd = new Downloader
        console.log(Config.podcast_data)
        nd.setOutput(Config.podcast_data)
        nd.download(@get("podurl")) #Url.parse(@get("podurl")).href)
        vars = {}
        vars.source_file = nd.outfile
        @set(vars)
        @save

        #options = Url.parse(@get("podurl"))
        #console.log(options)
        #o = { host:options.host, port:options.port, path:options.pathname }
        #o["type"] = "tcp6"
        #console.log("options", o)
        #fetcher = http.get o, (res) =>
        #      console.log("Got response: " + res.statusCode, res)
        #      callback(null, null)
        nd.on 'success', =>
            @set "download": "done"
            @save()
            # start transititon

            callback(null, this)
        nd.on 'failed', (err) =>
            console.log("Got error: " + err.message)
            @set "last_error": err, "download": "failed"
            @save()
            callback(err, null)
        nd.on 'progress', (progress) =>
            if parseInt(progress)%10 == 0
                @set "progress": progress
                @save()


    _id: () =>
        #console.log "_id", safe_url(@get("podurl"))
        rv =  "podcast_" + safe_url(@get("podurl"))
        #console.log(rv)
        return rv

    # returns data for update
    filteredJSON: () =>
        rv = @toJSON()
        for c in TYPES + ["cues"]
           delete rv[c]
        return rv

    _merge_save: (callback) =>
        Config.db.get @_id(), (err, res) =>
            console.log("_merge save", err, res)
            doc = @filteredJSON()
            console.log("this doc", doc)
            if res
                for key, value of res
                    if doc[key] == undefined
                        true #doc[key] = value

                doc._rev = res._rev
                #console.log("rev", doc._rev, res._rev)

            for c in TYPES
                nv = {}
                # copy current source
                if res
                    for own key, value of res[c]
                        nv[key] = value
                for own key, value of @get(c)
                    nv[key] = value

                doc[c] = nv
                @set c:nv
            #console.log("done", doc)
            Config.db.save @_id(), doc._rev, doc, (err, res) =>
                #console.log("config merge save", err, res)
                if res and res[0] and res[0].rev
                    true
                    @set _rev:res[0].rev

                callback err, res


    save: (callback) =>
        #console.log("save model")
        if not @get("podurl")
            throw new Error("podurl is required")
        changed = @changedAttributes()
        #console.log("changed", changed)
        data = @filteredJSON()
        data["_id"] = @_id()
        data["type"] = "podcast"
        is_new = not data["_rev"]
        data["id"] = data["name"] = @get("podurl")
        #console.log("data", data, @_id())
        #console.log "ServerPodcast", @
        if is_new
            Config.db.save [data], data, (err, res) =>
                console.log("saved error:", err, res)
                #if res
                #    @set "_rev":(res.rev or "xxx")
                callback(err, res) if callback
        else
            #console.log("merge")
            #delete data["_id"]
            #delete data["id"]
            #console.log(data)
            # data["_rev"]
            ndata = { _id: data._id }
            ndata["progress"] = data.progress
            ndata = data
            @_merge_save (err) =>
                callback(err, this) if callback
#            Config.db.merge ndata, (err, res) =>
#                console.log("merge saved error:", err, res)
#                if res
#                    @set "_rev":(res.rev or "xxx")
#                callback(err, this) if callback

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

module.exports = { ServerPodcast, ServerPodcastCollection, TYPES, Converter }

