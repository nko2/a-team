WaveformView = require('./waveform')
CueView = require('./cue')
{ Podcast } = require('../models/podcast')
{ Cue } = require('../models/cue')
Backbone = require('backbone')

Backbone.sync = require('../models/sync')

class ContentView extends Backbone.View
    initialize: (@url) ->
        @podcast = new Podcast( url: @url )
        @podcast.get('cues').bind 'add', (cue) =>
            view = new CueView @, cue
            @cueViews.push view
            if @cueToEdit is cue
                view.editText()
                delete @cueToEdit
        @podcast.fetch()

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

        @cueViews = [
            # STUBS:
            new CueView(@, new Cue(type: 'comment', start: 10, end: 20)),
            new CueView(@, new Cue(type: 'chapter', start: 0, end: 305)),
            new CueView(@, new Cue(type: 'note', start: 40, end: 60))
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
        @zoomTo @zoomStart + (zoomSpan * 0.2), @zoomEnd - (zoomSpan * 0.2)

    zoomOut: (ev) ->
        ev.preventDefault()
        zoomSpan = @zoomEnd - @zoomStart
        @zoomTo @zoomStart - (zoomSpan * 0.3), @zoomEnd + (zoomSpan * 0.3)

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
        for view in @cueViews
            @moveCue view

    moveCue: (view) ->
        fullWidth = @getFullWidth()
        left = fullWidth * view.model.get('start') / @length
        width = fullWidth * (view.model.get('end') - view.model.get('start')) / @length
        view.moveTo(Math.floor(left), Math.ceil(width), categoryToY(view.model.get('type')))

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
            $(@).css('top', "#{118 - top + categoryToY(i)}px")

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
            if @dragging.pos is 'start' and t < @dragging.cue.model.get('end')
                @dragging.cue.model.set start: t
            if @dragging.pos is 'end' and t > @dragging.cue.model.get('start')
                @dragging.cue.model.set end: t
            @moveCue @dragging.cue

    dragStop: (ev) ->
        ev.preventDefault()
        if @dragging
            cue = @dragging.cue.model
            # First remove
            delete @dragging
            # Then attempt syncing
            cue.save()

    pointCreate: (ev) ->
        ev.preventDefault()
        type = yToCategory(ev.offsetY or ev.layerY)
        t = @length * ((ev.offsetX or ev.layerX) + @el.scrollLeft()) / @getFullWidth()
        if type
            cue = new Cue(type: type, start: t, end: t + 10, podcast: @url)
            @podcast.get('cues').add cue
            @cueToEdit = cue
            cue.save()

module.exports = ContentView

CATEGORIES = ['chapter', 'transcription', 'note', 'comment']

categoryToY = (category) ->
    if typeof category is 'string'
        i = Math.max 0, CATEGORIES.indexOf(category)
    else
        i = category
    192 + 48 * i

yToCategory = (y) ->
    y -= 192
    CATEGORIES[Math.floor(y / 48)]
