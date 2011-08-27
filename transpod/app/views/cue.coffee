class CueView extends Backbone.View
    initialize: (@model) ->
        @el = $('<p class="cue"></p>')
        @el.text "Hello, World"
        $('#content').append(@el)

        # STUB:
        @type = @model.type
        @start = @model.start
        @end = @model.end

        switch @type
            when 'chapter'
                @el.css('background-color', '#d1e')
            when 'transcription'
                @el.css('background-color', '#cd0')
            when 'note'
                @el.css('background-color', '#28e')
            when 'comment'
                @el.css('background-color', '#b72')

module.exports = CueView
