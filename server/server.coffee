root = global ? window

require = __meteor_bootstrap__.require
request = require('request')
bambooURL = 'http://localhost:8080'
datasetsURL = bambooURL + '/datasets'
summaryURLf = (id,group) -> datasetsURL + '/' + id + '/summary' + if group then '?group=' + group else ''

Meteor.methods(
    register_dataset: (url) ->
        console.log "server received url: " + url
        cursor = Datasets.find({url: url})
        if(!cursor.count())
            post_options =
                uri: datasetsURL
                method: 'POST'
                form: {url: url}
            request(post_options, (e, b, response) ->
                ts = Date.now()
                bambooID = JSON.parse(response).id
                Fiber(->
                    Datasets.insert
                        id: bambooID
                        url: url
                        cached_at: ts
                # else figure out caching
                ).run()
                request.get(summaryURLf(bambooID), (e, b, response) ->
                    Fiber(->
                        Datasets.update({id: bambooID}, {$set: {summary:JSON.parse(response)}})
                    ).run()
                )
            )
    summarize_by_group: (obj) ->
        [bambooID, group] = obj
        #TODO: caching of group summaries
        cached = false
        for item in Datasets.find({id:bambooID}).fetch()[0].bummary
            if item[group]
                cached = true

        if !(cached)
            console.log "caching"
            request.get(summaryURLf(bambooID, group), (e, b, response) ->
                    obj = {}
                    obj[group] = JSON.parse(response)
                    Fiber(-> 
                        Datasets.update({id: bambooID}, {$addToSet: {bummary: obj}})
                    ).run()
            )
        else
            console.log "already cached"
)
