
routes = (app) ->
   app.get '/', (req, res, next) ->
       console.log("bla")
       next(req, res)
   
   app.get '/user/:id', (req, res, next) ->
       console.log(res)

module.exports = routes
