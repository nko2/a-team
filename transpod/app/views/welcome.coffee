{ Podcast, PodcastCollection } = require('../models/podcast')

collection = new PodcastCollection(socket)

HITLIST =
    "NodeUp: One": "http://www.archive.org/download/NodeupEp1/Nodeup-Episodeone.mp3"
    "NodeUp: Two": "http://ia600505.us.archive.org/26/items/nodeup2/nodeup2.mp3"
    "NodeUp: Three": "http://www.archive.org/download/NodeupThree/NodeUpThree.mp3"
    "ES6 Lives": "http://feedproxy.google.com/~r/AMinuteWithBrendan/~5/14P4PLIY3_8/amwb-20110805.mp3"
    "PDF ala JS": "http://minutewith.s3.amazonaws.com/amwb-20110616.ogg"
    "Pentacast 32": "http://ftp.c3d2.de/pentacast/pentacast-32-email-usage.mp3"
    "Pentacast 34": "http://ftp.c3d2.de/pentacast/pentacast-34-hackerspace-surveys-camp-ccc-hacker.mp3"

class WelcomeView extends Backbone.View
    initialize: ->
        @el = $('#welcome')
        @delegateEvents()
        for title, url of HITLIST
            do (title, url) =>
                li = $('<li><a></a></li>')
                li.find('a').text(title)
                li.find('a').click =>
                    @onUrl url
                @$('ul').append(li)

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
