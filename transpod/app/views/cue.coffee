class CueView extends Backbone.View
    constructor: (@contentView, @model) ->
        @el = $('<p class="cue"><span class="grab grabstart" title="Drag to change cue start">&nbsp;</span><span class="text" title="Edit cue text. Clear all to remove."></span><span class="grab grabend" title="Drag to change cue end">&nbsp;</span></p>')
        @$('.text').text @model.get('text')
        if @model.get('type') isnt 'comment'
            @el.append('<a class="edit" title="Edit">✎</a>')
        $('#content').append(@el)

        super()

        @model.bind 'change', =>
            @contentView.moveCue @
            @$('.text').text @model.get('text')
        @el.addClass @model.get('type')

    events:
        'mousedown .grabstart': 'dragStart'
        'mousedown .grabend': 'dragEnd'
        'mousemove': 'drag'
        'mouseup': 'dragStop'
        'mouseeup .grab': 'dragStop'
        'click .edit': 'clickEdit'

    clickEdit: (ev) ->
        if ev
            ev.preventDefault()

        @$('.text, .edit').addClass 'hidden'
        unless @form
            @form = new EditForm(@model.get('text'))
            @el.append @form.el
            @form.onOkay = (text) =>
                @model.set text: text
                @model.save()
                @$('.text, .edit').removeClass 'hidden'
                delete @form

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
        @el = $('<form><input class="edittext"><input class="editok" type="submit" value="Ok"></form>')
        super()
        @$('.edittext').val text
        # After attaching to DOM
        setTimeout =>
            @fit()
            @$('.edittext').focus()
        , 1

    fit: ->
        @$('.edittext').css 'width', "#{@el.innerWidth() - @$('.editok').outerWidth() - 10}px"

    events:
        'keypress .edittext': 'textkey'
        'keydown .edittext': 'textkey'
        'click .editok': 'okay'
        'submit': 'okay'

    textkey: (ev) ->
        if ev and (ev.keyCode is 10 or ev.keyCode is 13)
            ev.preventDefault()
            @okay(ev)

    okay: (ev) ->
        if ev
            ev.preventDefault()

        @el.detach()
        if @onOkay
            @onOkay @$('.edittext').val()

module.exports = CueView
