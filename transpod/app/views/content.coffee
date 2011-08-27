WaveformView = require('./waveform')
CueView = require('./cue')
{ Podcast } = require('../models/podcast')

class ContentView extends Backbone.View
    initialize: (url) ->
        @podcast = new Podcast({ url })
        #@podcast.save()

        @el = $('#content')
        @delegateEvents()
        @el.scroll =>
            @setZoomToScroll()
            @realign()
        $(window).scroll =>
            @realign()
        @length = 600 # STUB

        @audio = document.createElement('audio')
        src = document.createElement('source')
        src.setAttribute('src', @url)
        @audio.appendChild(src)
        @audio.addEventListener 'load', =>
            @length = @audio.duration
        @audio.load()

        @waveform = new WaveformView()

        @cues = [
            # STUBS:
            new CueView(@, type: 'comment', start: 10, end: 20),
            new CueView(@, type: 'chapter', start: 0, end: 305),
            new CueView(@, type: 'note', start: 40, end: 60)
        ]
        @realign()

    events:
        'click #zoomin': 'zoomIn'
        'dblclick #zoomin': 'zoomIn'
        'click #zoomout': 'zoomOut'
        'dblclick #zoomout': 'zoomOut'
        'mousemove': 'drag'
        'mouseup': 'dragStop'
        'mousedown': 'pointCreate'

    zoomIn: (ev) ->
        ev.preventDefault()
        zoomSpan = @zoomEnd - @zoomStart
        @zoomTo @zoomStart + (zoomSpan * 0.25), @zoomEnd - (zoomSpan * 0.25)

    zoomOut: (ev) ->
        ev.preventDefault()
        zoomSpan = @zoomEnd - @zoomStart
        @zoomTo @zoomStart - (zoomSpan * 0.25), @zoomEnd + (zoomSpan * 0.25)

    getFullWidth: ->
        winWidth = @el.innerWidth()
        zoomSpan = @zoomEnd - @zoomStart
        Math.ceil(winWidth * @length / zoomSpan)

    zoomTo: (@zoomStart, @zoomEnd) ->
        # Normalize first
        if isNaN(@zoomStart)
            @zoomStart = 0
        if isNaN(@zoomEnd)
            @zoomEnd = @length
        if @zoomStart > @zoomEnd
            tmp = @zoomEnd
            @zoomEnd = @zoomStart
            @zoomStart = tmp
        if @zoomStart < 0
            @zoomStart = 0
        if @zoomEnd > @length
            @zoomEnd = @length
        @emitZoomUpdate()

        fullWidth = @getFullWidth()
        $('#dummy').css('left', "#{fullWidth - 4}px")
        @el.scrollLeft fullWidth * @zoomStart / @length

        # Move cues around:
        for cue in @cues
            @moveCue cue

    moveCue: (cue) ->
        fullWidth = @getFullWidth()
        left = fullWidth * cue.start / @length
        width = fullWidth * (cue.end - cue.start) / @length
        i = ['chapter', 'transcription', 'note', 'comment'].indexOf(cue.type)
        cue.moveTo(Math.floor(left), Math.ceil(width), 192 + 48 * i)

    setZoomToScroll: ->
        fullWidth = @getFullWidth()
        winWidth = @el.innerWidth()
        left = @el.scrollLeft()
        right = left + winWidth
        @zoomStart = left * @length / fullWidth
        @zoomEnd = right * @length / fullWidth
        @emitZoomUpdate()

    realign: ->
        # Fixed stuff:
        left = @el.scrollLeft()
        top = $(window).scrollTop() + @el.scrollTop()
        @waveform.el.css('left', "#{left}px").
            css('width', "#{@el.innerWidth()}px").
            css('top', "#{134 - top}.px")
        @$('#buttons').css('top', "#{278 - top}px")
        @$('h3').each (i) ->
            $(@).css('top', "#{310 - top + 48 * i}px")

    emitZoomUpdate: ->
        if @onZoomUpdate
            @onZoomUpdate @zoomStart, @zoomEnd

    beginDrag: (cue, pos) ->
        unless @dragging
            @dragging = { cue, pos }

    drag: (ev) ->
        ev.preventDefault()
        if @dragging
            if ev.target is @el[0]
                x = @el.scrollLeft() + (ev.offsetX or ev.layerX)
            else
                x = @el.scrollLeft() + ev.pageX - @el[0].offsetLeft
            t = x * @length / @getFullWidth()
            if @dragging.pos is 'start' and t < @dragging.cue.end
                @dragging.cue.start = t
            if @dragging.pos is 'end' and t > @dragging.cue.start
                @dragging.cue.end = t
            @moveCue @dragging.cue

    dragStop: (ev) ->
        ev.preventDefault()
        delete @dragging

    pointCreate: (ev) ->
        ev.preventDefault()

module.exports = ContentView
