class CueView extends Backbone.View
    constructor: (@contentView, @model) ->
        @el = $('<p class="cue"><span class="grab grabstart" title="Drag to change cue start">&nbsp;</span><span class="text" contentEditable="true" title="Edit cue text. Clear all to remove."></span><a class="edit" title="Edit">☑</a><span class="grab grabend" title="Drag to change cue end">&nbsp;</span></p>')
        @$('.text').text("Hello World #{Math.ceil(Math.random() * 23)}")
        $('#content').append(@el)

        super()

        @model.bind 'change', =>
            @contentView.moveCue @
        @el.addClass @model.get('type')

    events:
        'mousedown .grabstart': 'dragStart'
        'mousedown .grabend': 'dragEnd'
        'mousemove': 'drag'
        'mouseup': 'dragStop'
        'mouseeup .grab': 'dragStop'
        'change .text': 'textEdited'
        'textInput .text': 'textEdited'
        'keypress .text': 'textEdited'
        'keyup .text': 'textEdited'
        'click .text': 'editText'

    editText: (ev) ->
        @$('.text').focus()

    textEdited: (ev) ->
        console.log 'textEdited', ev
        wasReturn = false
        if ev and
           (ev.keyCode is 10 or ev.keyCode is 13)
            wasReturn = true
        text = @$('.text').text()
        if text.indexOf("\n") >= 0
            text = text.slice(0, text.indexOf("\n"))
            @$('.text').text(text)
            wasReturn = true

        if wasReturn
            ev.preventDefault()
            @$('.text').blur()
            text = @$('.text').text()
            @model.set text: text
            @model.save()

    # Move whole cue
    moveTo: (left, width, top) ->
        @el.css('left', "#{left}px").
            css('width', "#{width}px").
            css('z-index', "#{left}")
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

    dragStop: (ev) ->
        @contentView.dragStop ev

module.exports = CueView
