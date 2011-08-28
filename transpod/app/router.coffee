WelcomeView = require('./views/welcome')
ContentView = require('./views/content')
Timefmt = require('./timefmt')

$(document).ready ->
    class Router extends Backbone.Router
        initialize: ->
            $('#content').hide()

            @welcomeView = new WelcomeView()
            @welcomeView.onUrl = (s) =>
                @navigate @displayUrl(0, 60, s), true

            Backbone.history.start()

        routes:
            "": "hello"
            "from :start to :end of *url": "display"

        hello: ->

        displayUrl: (start, end, url) ->
            s = Timefmt.toString
            "from #{s start} to #{s end} of #{url}"

        display: (start, end, url) ->
            @contentView = new ContentView(url)
            @contentView.onZoomUpdate = (start, end) =>
                @navigate @displayUrl(start, end, url), false
            @contentView.zoomTo Timefmt.parse(start), Timefmt.parse(end)
            @contentView.el.slideDown(200)
            @welcomeView.el.slideUp(200)

    router = new Router()

