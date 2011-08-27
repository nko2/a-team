{ Podcast, PodcastCollection } = require('../models/podcast')

collection = new PodcastCollection(socket)

class WelcomeView extends Backbone.View
    initialize: ->
        @el = $('#welcome')
        @delegateEvents()

    events:
        'click #fresh_ok': 'freshOk'
        'submit form': 'freshOk'

    freshOk: (ev) ->
        ev.preventDefault()

        # Hooked by router:
        if @onUrl
            url = @$('#fresh_url').val()
            @onUrl url

module.exports = WelcomeView
