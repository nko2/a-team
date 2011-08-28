vows = require 'vows'
Config = require('../config')
assert = require('assert')
{ Downloader } = require('../server/downloader')
{ Converter, ServerPodcast } = require('../server/model/podcast')

tests = vows.describe('download tests').addBatch [
    'test download':
        topic: () ->
            d = new Downloader()
            d.setOutput(Config.podcast_data)
            console.log(d)
            d.download("http://phobos.hq.c3d2.de/pentaradio-2011-07-26.mp3")
            callback = this.callback
            d.on "success", -> callback("success")
            d.on "error", -> callback("error")
            d.on "progress", (prog) =>
                console.log("progress", prog)
                @progress = prog
            
            console.log("test")
            return
        "schould ok": (ok) ->
            assert.equal(ok, "success")
            assert.equal(@progress, "100%", "not full downloaded")
            console.log(ok)

    'test should fail':
        topic: () ->
           d = new Downloader()
           d.setOutput(Config.podcast_data)
           console.log(d)
           callback = this.callback
           d.on 'failed', (err) ->
               callback(null, err)
           d.download("http://some.none.existing.host/uaie.com")
           console.log("test")
           return
        "schould ok": (ok) ->
            assert.equal(ok, 'error in wget: 4')
            console.log(ok)
,
    'test converter':
        topic: () ->
            c = new Converter("../podcast_data/http_3A_2F_2Fphobos.hq.c3d2.de_2Fpentaradio-2011-07-26.mp3")
            callback = this.callback
            c.on "sample", (sample) ->
                #console.log("sample", sample)
                process.stdout.write('.')
            c.run (err, x) ->
                console.log("converter done")
                callback(err, x)
            return

        "bla": (x) ->
            console.log("bla")
]

tests.export(module)
