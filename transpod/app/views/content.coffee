class @ContentView extends Backbone.View
    initialize: (@url) ->
        @el = $('#content')

        @audio = document.createElement('audio');
        src = document.createElement('source')
        src.setAttribute('src', @url)
        @audio.appendChild(src)
        @audio.addEventListener 'load', =>
            console.log 'duration', @audio.duration
        @audio.load()

        @zoomStart = 0