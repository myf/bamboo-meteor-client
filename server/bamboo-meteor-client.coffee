root = global ? window

require = __meteor_bootstrap__.require
request = require('request')

Meteor.methods(
    register_dataset: (url) ->
        console.log('got to the server' + url)
        post_options =
            uri: 'http://localhost:8080/datasets'
            method: 'POST'
            body: JSON.stringify({url: url})
        console.log(post_options)
        request(post_options, (error, body, response) ->
            console.log(response)
        )
)
