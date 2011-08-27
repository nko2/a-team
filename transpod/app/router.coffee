$(document).ready ->
    class Router extends Backbone.Router
        initialize: ->
            $('#content').hide()

            @welcomeView = new require('views/welcome')()
            @welcomeView.onUrl = (s) =>
                @navigate @displayUrl(0, 0, 60, s), true

            Backbone.history.start()

        routes:
            "": "hello"
            "at :at from :start to :end of *url": "display"

        hello: ->

        displayUrl: (at, start, end, url) ->
            cap = (n) ->
                s = "#{n}"
                if (m = /^(.+\.\d{0,3})/.exec(s))
                    m[1]
                else
                    s
            "at #{cap at} from #{cap start} to #{cap end} of #{url}"

        display: (at, start, end, url) ->
            @contentView = new require('views/content')(url)
            #@contentView.seekTo at
            @contentView.onZoomUpdate = (start, end) =>
                @navigate @displayUrl(at, start, end, url), false
            @contentView.zoomTo start, end
            @contentView.el.slideDown(200)
            @welcomeView.el.slideUp(200)

    router = new Router()

