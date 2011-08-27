class CueView extends Backbone.View
    initialize: (@model) ->
        @el = $('<p class="cue"></p>')
        @el.text "Hello, World"
        $('#content').append(@el)

        # STUB:
        @type = @model.type
        @start = @model.start
        @end = @model.end

        @el.addClass @type

module.exports = CueView
