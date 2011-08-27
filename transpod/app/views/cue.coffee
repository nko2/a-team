class CueView extends Backbone.View
    initialize: (@contentView, @model) ->
        @el = $('<p class="cue"><span class="grab grabstart">&nbsp;</span><span class="text"></span><span class="grab grabend">&nbsp;</span></p>')
        @$('.text').text("Hello World #{Math.ceil(Math.random() * 23)}")
        $('#content').append(@el)

        @delegateEvents()

        # STUB:
        @type = @model.type
        @start = @model.start
        @end = @model.end

        @el.addClass @type

    events:
        'mousedown .grabstart': 'dragStart'
        'mousedown .grabend': 'dragEnd'
        'mousemove': 'drag'

    # Move whole cue
    moveTo: (left, width, top) ->
        console.log "move cue", left, width, top
        @el.css('left', "#{left}px").
            css('width', "#{width}px")
        if top
            @el.css('top', "#{top}px")

    dragStart: (ev) ->
        ev.preventDefault()
        @contentView.beginDrag @, 'start'

    dragEnd: (ev) ->
        ev.preventDefault()
        @contentView.beginDrag @, 'end'

    drag: (ev) ->
        ev.preventDefault()
        @contentView.drag ev

module.exports = CueView
