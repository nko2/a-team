config = require('../config')
kue = require('kue')
cradle = require('cradle')
jobs = kue.createQueue()
path = require('path')
fs = require('fs')

{ ServerPodcast, ServerPodcastCollection, TYPES, Converter } = require('./model/podcast')
{ Downloader } = require('./downloader')
Waveform = require('./waveform_render')

collection = new ServerPodcastCollection()

config.db = db = new(cradle.Connection)({
    cache: false,
    raw: false
}).database('transpod')


jobs.process 'download', 3, (job, done) ->
    console.log("job download", job)
    collection.get_for_url job.data.url, (err, podcast) ->
        if not podcast
            return done("not existing")
        podcast.download (err) =>
            console.log("download done", err)
            if not err
                jobs.create("convert", url:job.data.url).save()
                done()
            else
                done(err)

jobs.process 'convert', 1, (job, done) ->
    console.log("job convert", job.data)
    collection.get_for_url job.data.url, (err, podcast) ->
        console.log(err, podcast)
        if not podcast
            console.log("podcast missing")
            done("does not exist")
        source = podcast.get("source_file")
        if not source
            return done("source file missing in model")
        dir = podcast.generate_filename("")
        if not path.existsSync(dir)
            fs.mkdirSync(dir)
        conv = new Converter(podcast.get("source_file"), podcast.generate_filename("audio"))
        render = new Waveform.SeriesRenderer()
        render.on 'image', (png, start, stop) ->
            console.log(path.join(dir, "uv-#{start}-#{stop}.png"))
            fs.writeFileSync path.join(dir, "uv-#{start}-#{stop}.png"), png
        conv.on "sample", (value) =>
            render.write(value)
        conv.run (err, n) =>
            done(err)
        podcast.set {"status":"converting"}
        podcast.save()



