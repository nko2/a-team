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

    events:
        'click #zoomin': 'zoomIn'
        'dblclick #zoomin': 'zoomIn'
        'click #zoomout': 'zoomOut'
        'dblclick #zoomout': 'zoomOut'
        'mousemove': 'drag'
        'mouseup': 'dragStop'

    zoomIn: (ev) ->
        ev.preventDefault()
        console.log "zoomIn"
        zoomSpan = @zoomEnd - @zoomStart
        @zoomTo @zoomStart + (zoomSpan * 0.25), @zoomEnd - (zoomSpan * 0.25)

    zoomOut: (ev) ->
        ev.preventDefault()
        console.log "zoomOut"
        zoomSpan = @zoomEnd - @zoomStart
        @zoomTo @zoomStart - (zoomSpan * 0.25), @zoomEnd + (zoomSpan * 0.25)

    getFullWidth: ->
        winWidth = @el.innerWidth()
        zoomSpan = @zoomEnd - @zoomStart
        Math.ceil(winWidth * @length / zoomSpan)

    zoomTo: (@zoomStart, @zoomEnd) ->
        console.log "zoomTo #{@zoomStart} #{@zoomEnd}"
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
        console.log "zoomTo' #{@zoomStart} #{@zoomEnd}"

        fullWidth = @getFullWidth()
        #@el.css('width', "#{fullWidth}px")
        console.log("fullWidth=#{fullWidth}")
        $('#dummy').css('left', "#{fullWidth - 4}px")
        console.log "scroll to #{Math.floor(@zoomStart * fullWidth / @length)}"
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
        console.log "setZoomToScroll l=#{left} r=#{right} ww=#{winWidth} zs=#{@zoomStart} ze=#{@zoomEnd}"
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
        console.log "drag #{pos} of #{cue.el.text()}"
        unless @dragging
            @dragging = { cue, pos }

    drag: (ev) ->
        ev.preventDefault()
        if @dragging
            t = (@el.scrollLeft() + ev.offsetX) * @length / @getFullWidth()
            if @dragging.pos is 'start' and t < @dragging.cue.end
                @dragging.cue.start = t
            if @dragging.pos is 'end' and t > @dragging.cue.start
                @dragging.cue.end = t
            @moveCue @dragging.cue

    dragStop: (ev) ->
        ev.preventDefault()
        console.log 'dragStop'
        delete @dragging

module.exports = ContentView
