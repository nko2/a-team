WaveformView = require('./waveform')
CueView = require('./cue')
{ Podcast } = require('../models/podcast')
{ Cue } = require('../models/cue')
Backbone = require('backbone')
Timefmt = require('../timefmt')

Backbone.sync = require('../models/sync')

class ContentView extends Backbone.View
    initialize: (@url) ->
        @podcast = new Podcast( url: @url )
        @podcast.get('cues').bind 'add', (cue) =>
            @newCue cue
        @podcast.fetch()

        @el = $('#content')
        @delegateEvents()
        @el.scroll =>
            @setZoomToScroll()
            @realign()
        $(window).scroll =>
            @realign()
        $(window).resize =>
            @zoomTo @zoomStart, @zoomEnd
        @length = 600 # STUB

        @audio = document.createElement('audio')
        src = document.createElement('source')
        src.setAttribute('src', @url)
        @audio.appendChild(src)
        @audio.addEventListener 'load', =>
            if @audio.duration
                @length = @audio.duration
                @zoomTo @zoomStart, @zoomEnd
        @audio.addEventListener 'playing', =>
            @$('#play').text "▮▮"
            @startPlayTimer()
        @audio.addEventListener 'play', =>
            @$('#play').text "▮▮"
            @startPlayTimer()
        @audio.addEventListener 'pause', =>
            @$('#play').text "▶"
        @audio.load()
        @startPlayTimer()

        @waveform = new WaveformView()
        @waveselection = @$('#waveselection')
        @waveselection.hide()
        @timehints =
            start: @$('#starthint')
            end: @$('#endhint')
        @timehints.start.hide()
        @timehints.end.hide()

        @cueViews = []
        @realign()

    remotePushed: (obj) ->
        console.log 'got pushed', obj
        if obj.type is 'podcast'
            @podcast.set obj
        if CATEGORIES.indexOf(obj.type) >= 0
            found = false
            @podcast.cues.forEach (cue) ->
                if cue.uid is obj.uid
                    cue.set obj
                    found = true
            unless found
                @podcast.cues.add cue

    newCue: (cue) ->
        if _.any(@cueViews, (view) -> view.model is cue)
            return

        view = new CueView @, cue
        @moveCue view
        @cueViews.push view
        view.onEdit = =>
            # When its clicked
            for view1 in @cueViews
                # All other views
                unless view1 is view
                    # Shall close their edit inputs
                    view1.editDone()
        view

    events:
        'click #play': 'clickPlay'
        'mousedown #zoomin': 'zoomIn'
        'mousedown #zoomout': 'zoomOut'
        'mouseup #zoomin': 'stopZooming'
        'mouseup #zoomout': 'stopZooming'
        'mousemove': 'drag'
        'mouseup': 'mouseup'
        'mousedown': 'pointCreate'
        'mousedown #waveform': 'seekStart'
        'mousemove #waveform': 'seekMove'
        'mouseup #waveform': 'seekStop'
        'click #center': 'zoomCenter'

    mouseup: (ev) ->
        @dragStop ev
        @stopZooming ev
        @seekStop ev

    startZooming: (factor) ->
        zoomSpan = @zoomEnd - @zoomStart
        @zoomTo @zoomStart + (zoomSpan * factor), @zoomEnd - (zoomSpan * factor)

        unless @zoomTimeout
            @zoomTimeout = setTimeout( =>
                delete @zoomTimeout
                @startZooming factor
            , 40)

    stopZooming: ->
        if @zoomTimeout
            clearTimeout @zoomTimeout
            delete @zoomTimeout

    zoomIn: (ev) ->
        ev.preventDefault()
        @startZooming 0.01

    zoomOut: (ev) ->
        ev.preventDefault()
        @startZooming -0.02

    zoomCenter: (ev) ->
        ev.preventDefault()
        if isNaN(@audio.currentTime)
            return

        zoomSpan = @zoomEnd - @zoomStart
        @zoomTo @audio.currentTime - zoomSpan / 2, @audio.currentTime + zoomSpan / 2

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

        @updateSeeker()

    moveCue: (view) ->
        fullWidth = @getFullWidth()
        left = fullWidth * view.model.get('start') / @length
        width = fullWidth * (view.model.get('end') - view.model.get('start')) / @length
        view.moveTo(Math.floor(left), Math.ceil(width), categoryToY(view.model.get('type')))

    updateSeeker: ->
        if isNaN(@audio.currentTime)
            left = -1
        else
            left = @getFullWidth() * @audio.currentTime / @length
        @$('#seeker').css('left', "#{Math.floor left}px")

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
        top = $(window).scrollTop() + @el.scrollTop()
        @$('#waveform').css('top', "#{142 - top}px")
        @$('#buttons').css('top', "#{72 - top}px")
        @$('h3').each (i) ->
            $(@).css('top', "#{108 - top + categoryToY(i)}px")

    emitZoomUpdate: ->
        if @onZoomUpdate
            @onZoomUpdate @zoomStart, @zoomEnd

    beginDrag: (cue, pos) ->
        unless @dragging
            @dragging = { cue, pos }
            @updateWaveSelection()
            @waveselection.show()

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
            @updateWaveSelection()
            @timehints.start.fadeIn(200)
            @timehints.end.fadeIn(200)

    dragStop: (ev) ->
        ev.preventDefault()
        if @dragging
            cue = @dragging.cue.model
            # First remove
            delete @dragging
            # Then attempt syncing
            cue.save()
            @waveselection.fadeOut(1000)
            @timehints.start.fadeOut(500)
            @timehints.end.fadeOut(500)

    updateWaveSelection: ->
        start = @dragging.cue.model.get('start')
        end = @dragging.cue.model.get('end')
        fullWidth = @getFullWidth()
        left = start * fullWidth / @length
        width = (end - start) * fullWidth / @length
        @waveselection.css('left', "#{left}px").
            css('width', "#{width}px")
        @timehints.start.text(Timefmt.toString(start))
        @timehints.end.text(Timefmt.toString(end))
        top = categoryToY(@dragging.cue.model.get('type')) + 8
        @timehints.start.css('top', "#{top}px")
        @timehints.end.css('top', "#{top}px")
        @timehints.start.css('left', "#{left - 1 - @timehints.start.innerWidth()}px")
        @timehints.end.css('left', "#{left + width + 3}px")

    pointCreate: (ev) ->
        ev.preventDefault()
        type = yToCategory(ev.offsetY or ev.layerY)
        t = @length * ((ev.offsetX or ev.layerX) + @el.scrollLeft()) / @getFullWidth()
        switch type
            when 'chapter'
                l = 60
            when 'transcript'
                l = 10
            when 'note'
                l = 5
            else
                l = 1
        if type
            view = @newCue new Cue(type: type, start: t, end: t + l, podcast: @url)
            view.clickEdit()

    clickPlay: (ev) ->
        ev.preventDefault()

        if @audio.paused
            @audio.play()
        else
            @audio.pause()

    startPlayTimer: ->
        @$('#playtime').text Timefmt.toString(@audio.currentTime)
        # Maybe scroll?
        @updateSeeker()

        unless @audio.paused or @playTimer
            @playTimer = setTimeout =>
                delete @playTimer
                @startPlayTimer()
            , 40

    seekStart: (ev) ->
        @seeking = true
        @seekMove ev

    seekMove: (ev) ->
        unless @seeking
            return

        @audio.currentTime = @length * ((ev.offsetX or ev.layerX) + @el.scrollLeft()) / @getFullWidth()
        @startPlayTimer()

    seekStop: (ev) ->
        delete @seeking

module.exports = ContentView

CATEGORIES = ['chapter', 'transcript', 'note', 'comment']
CATEGORIES_OFFSET = 10 + 128 + 10 + 28
CATEGORY_HEIGHT = 64

categoryToY = (category) ->
    if typeof category is 'string'
        i = Math.max 0, CATEGORIES.indexOf(category)
    else
        i = category
    CATEGORIES_OFFSET + CATEGORY_HEIGHT * i

yToCategory = (y) ->
    y -= CATEGORIES_OFFSET
    CATEGORIES[Math.floor(y / CATEGORY_HEIGHT)]
