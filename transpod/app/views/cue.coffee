class CueView extends Backbone.View
    constructor: (@contentView, @model) ->
        @el = $('<p class="cue"><span class="grab grabstart" title="Drag to change cue start">&nbsp;</span><span class="text" title="Edit cue text. Clear all to remove."></span><span class="grab grabend" title="Drag to change cue end">&nbsp;</span></p>')
        @$('.text').text @model.get('text')
        $('#content').append(@el)

        super()

        @model.bind 'change', =>
            @render()
        @el.addClass @model.get('type')

    render: ->
        @contentView.moveCue @
        @$('.text').text @model.get('text')
        @$('.text').attr 'title', "Edit: “#{@model.get('text')}”"

    events:
        'mousedown .grabstart': 'dragStart'
        'mousedown .grabend': 'dragEnd'
        'mousemove': 'drag'
        'mouseup': 'dragStop'
        'mouseeup .grab': 'dragStop'
        'click .text': 'clickEdit'

    clickEdit: (ev) ->
        if ev
            ev.preventDefault()

        @$('.text').hide()
        unless @form
            if @onEdit
                # Signal ContentView to close all other edits
                @onEdit(@)

            @form = new EditForm(@model.get('text'))
            @el.append @form.el
            @form.onOkay = =>
                @editDone()

    editDone: ->
        if @form
            @model.set text: @form.getText()
            @form.detach()
            delete @form
            @model.save()
            @render()
            @$('.text').show()

    # Move whole cue
    moveTo: (left, width, top) ->
        @el.css('left', "#{left}px").
            css('width', "#{width}px").
            css('z-index', "#{left}")
        if top
            @el.css('top', "#{top}px")
        if @form
            @form.fit()

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

class EditForm extends Backbone.View
    constructor: (text) ->
        @el = $('<form><input class="edittext"></form>')
        super()
        @$('.edittext').val text
        # After attaching to DOM
        setTimeout =>
            @fit()
            @$('.edittext').focus()
        , 1

    fit: ->
       @$('.edittext').css 'width', "#{@el.innerWidth() - 8}px"

    events:
        'keypress .edittext': 'textkey'
        'keydown .edittext': 'textkey'
        'submit': 'okay'

    textkey: (ev) ->
        if ev and (ev.keyCode is 10 or ev.keyCode is 13)
            ev.preventDefault()
            @okay(ev)

    okay: (ev) ->
        if ev
            ev.preventDefault()

        if @onOkay
            @onOkay()

    getText: ->
        @$('.edittext').val()

    detach: ->
        @el.detach()

module.exports = CueView
