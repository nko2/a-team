spawn = require('child_process').spawn
{EventEmitter} = require('events')
{Png} = require('png')

W = 128
H = 128
MAX_VAL = 1.0

class Image extends EventEmitter
    constructor: (@sampling) ->
        s = 0
        sample = 0
        x = 0
        rgb = new Buffer(W*H*3)


    write: (n) ->
        s += n
        sample += 1
        if sample > @sampling
            addColumn s / @sampling
            s = 0
            sample = 0

    addColumn: (v) ->
        y = H - Math.ceil(H * v / MAX_VAL)

        drawLine x, y
        x++
        if x >= W
            @emit 'end'

    drawColumn: (x, y1) ->
        for y in [0..(y1 - 1)]
            putPixel x, y, 0, 0, 63
        for y in [y1..(H - 1)]
            putPixel x, y, 127, 127, 255

    putPixel: (x, y, r, g, b) ->
            rgb[(x + y * W) * 3] = r
            rgb[(x + y * W) * 3] = g
            rgb[(x + y * W) * 3] = b

    toPNG: ->
        png = new Png(rgb, W, H, 'rgb');
        png.encodeSync()


class SeriesRenderer extends EventEmitter
    constructor: (minSampling=1, maxSampling=600) ->
        @sample = 0
        sampling = minSampling
        while sampling <= maxSampling
            startSampler sampling
            sampling *= 2

    write: (v) ->
        @emit 'sample', v
        @sample++

    startSampler: (sampling) ->
        start = @sample
        img = new Image(sampling)
        pipe = (v) -> img.write v
        @on 'sample', pipe
        img.on 'end', =>
            @emit 'image', img.toPNG(), Math.floor(start / W), Math.floor(@sample / W)

            @removeListener 'sample', pipe
            startSampler(sampling)

module.exports = { Image, SeriesRenderer }
