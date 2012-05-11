root = global ? window

require = __meteor_bootstrap__.require
request = require('request')
bambooURL = 'http://localhost:8080'

Meteor.methods(
    register_dataset: (url) ->
        console.log "server received url: " + url
        post_options =
            uri: bambooURL + '/datasets'
            method: 'POST'
            form: {url: url}
        request(post_options, (error, body, response) ->
            ts = Date.now()
            Fiber(->
                cursor = Datasets.find({url: url})
                if(!cursor.count())
                    Datasets.insert
                        id: JSON.parse(response).id
                        url: url
                        cached_at: ts
                # else figure out caching
                ###
                else
                    console.log cursor.fetch()
                ###
            ).run()
        )
)
