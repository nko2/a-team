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
                done()
            else
                done(err)

