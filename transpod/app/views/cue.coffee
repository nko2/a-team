class CueView extends Backbone.View
    initialize: (@model) ->
        @el = $('<p class="cue"><span class="grab grabstart">&nbsp;</span><span class="text"></span><span class="grab grabend">&nbsp;</span></p>')
        @$('.text').text('Hello World')
        $('#content').append(@el)

        # STUB:
        @type = @model.type
        @start = @model.start
        @end = @model.end

        @el.addClass @type

    moveTo: (left, width, top) ->
        console.log "cue top #{top}"
        @el.css('left', "#{left}px").
            css('width', "#{width}px").
            css('top', "#{top}px")
        @$('.grabend').css('left', "#{width - 1}px")

module.exports = CueView
