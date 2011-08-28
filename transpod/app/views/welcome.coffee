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
            #socket.send("blubb")
            #podurl = socket.of('/podcast').emit("create", url)
            url = @$('#fresh_url').val()
            console.log(url)
            collection.get_url url, (err, podcast) =>
                console.log("PodcastColl get", err, podcast)
            collection.fetch
                url: url
                success: (obj) ->
                    console.log("got", obj)
                error: (err) ->
                    console.log("blubb", err)
            #podcast = new Podcast({url: url})
            
            #podcast.save()

            #@onUrl url

module.exports = WelcomeView
