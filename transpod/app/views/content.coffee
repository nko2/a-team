class @ContentView extends Backbone.View
    initialize: (@url) ->
        @el = $('#content')
        @delegateEvents()
        @el.scroll =>
            @setZoomToScroll()
        @length = 600 # STUB

        @audio = document.createElement('audio');
        src = document.createElement('source')
        src.setAttribute('src', @url)
        @audio.appendChild(src)
        @audio.addEventListener 'load', =>
            @length = @audio.duration
        @audio.load()

        @waveform = new WaveformView()

        @cues = [
            # STUBS:
            new CueView(type: 'comment', start: 10, end: 20),
            new CueView(type: 'chapter', start: 0, end: 305),
            new CueView(type: 'note', start: 40, end: 60)
        ]

    events:
        'click #zoomin': 'zoomIn'
        'dblclick #zoomin': 'zoomIn'
        'click #zoomout': 'zoomOut'
        'dblclick #zoomout': 'zoomOut'

    zoomIn: (ev) ->
        ev.preventDefault()
        console.log "zoomIn"
        zoomSpan = @zoomEnd - @zoomStart
        @zoomTo @zoomStart + (zoomSpan * 0.1), @zoomEnd - (zoomSpan * 0.1)

    zoomOut: (ev) ->
        ev.preventDefault()
        console.log "zoomOut"
        zoomSpan = @zoomEnd - @zoomStart
        @zoomTo @zoomStart - (zoomSpan * 0.1), @zoomEnd + (zoomSpan * 0.1)

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
            left = fullWidth * cue.start / @length
            width = fullWidth * (cue.end - cue.start) / @length
            i = ['chapter', 'transcription', 'note', 'comment'].indexOf(cue.type)
            cue.el.css('left', "#{left}px").
                css('width', "#{width}px").
                css('top', "#{12.4 + 4 * i}em")

        @realign()

    setZoomToScroll: ->
        fullWidth = @getFullWidth()
        winWidth = @el.innerWidth()
        left = @el.scrollLeft()
        right = left + winWidth
        @zoomStart = left * @length / fullWidth
        @zoomEnd = right * @length / fullWidth
        console.log "setZoomToScroll l=#{left} r=#{right} ww=#{winWidth} zs=#{@zoomStart} ze=#{@zoomEnd}"
        @emitZoomUpdate()

        @realign()

    realign: ->
        console.log "realign #{@zoomStart}..#{@zoomEnd}"
        # Fixed stuff:
        left = @el.scrollLeft()
        @$('#buttons').css('left', "#{left}px").
            css('top', "7em")
        @waveform.el.css('left', "#{left}px").
            css('width', "#{@el.innerWidth()}px").
            css('top', "0.2em").
            css('height', "6.6em")
        @waveform.zoomTo @zoomStart, @zoomEnd
        @$('h3').each (i) ->
            console.log "i=#{i}"
            $(@).css('left', "#{left + 4}px").
                css('top', "#{11 + 4 * i}em")

    emitZoomUpdate: ->
        if @onZoomUpdate
            @onZoomUpdate @zoomStart, @zoomEnd
