update_design = (db, callback) ->
    db.save '_design/podcasts',
        all:
            map: (doc) ->
                if doc.type == "podcast"
                    emit(doc._id, doc)
        
        ready:
            map: (doc) ->
                if doc.type == "podcast" and doc.status == 'ready'
                    emit(doc._id, doc)
            
        , (err) ->
            console.log("saved schema", err)
            callback(err)

module.exports = update_design
