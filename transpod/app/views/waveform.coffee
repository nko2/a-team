# twobit draws a nice waveform here
class @WaveformView extends Backbone.View
    initialize: () ->
        @el = $('#waveform')
        #@canvas = @el[0].createContext...
        @delegateEvents()

    events:
        'click #foo': 'foo'

    foo: ->
        # Handle click on #foo here

    # called by ContentView
    # time in seconds
    zoomTo: (zoomStart, zoomEnd) ->

