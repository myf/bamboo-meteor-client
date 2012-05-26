root = global ? window

require = __meteor_bootstrap__.require
request = require('request')
bambooURL = 'http://localhost:8080'
datasetsURL = bambooURL + '/datasets'
summaryURLf = (id,group) -> datasetsURL + '/' + id + '/summary' + if group then '?group=' + group else ''

#Note: methods can live anywhere, regardless of server or client
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
                console.log response
                bambooID = JSON.parse(response).id
                Fiber(->
                    Datasets.insert
                        id: bambooID
                        url: url
                        cached_at: ts
                # else figure out caching
                ).run()
                callback = ->request.get(summaryURLf(bambooID), (e, b, response) ->
                    Fiber(->
                        Datasets.update({id: bambooID}, {$set: {summary:JSON.parse(response)}})
                    ).run()
                )
                setTimeout callback, 1000
            )
    summarize_by_group: (obj) ->
        # for [bambooID, groupkey], store set of objects that looks like
        # {groupkey: groupkey, groupval: val_in_group, data: data, name: name, datasetID: datasetID}
        [datasetID, groupkey] = obj
        dataset =  Datasets.findOne(_id: datasetID)
        return unless dataset
        bambooID = dataset.id
        if Datasets.findOne(datasetID: datasetID, groupkey: groupkey)
            console.log "group splits for " + groupkey + " on dataset " + datasetID already cached
        else
            request.get(summaryURLf(bambooID, groupkey), (e, b, response) ->
                    obj = JSON.parse(response) # a dict split by dict_val
                    console.log(obj)
                    console.log(_.map(_.keys(obj), (k) -> obj[k]))
                    f = (key) -> (dataEl) -> 
                            groupkey: groupkey
                            groupval: key
                            data: dataEl.data
                            name: dataEl.name
                            datasetID: datasetID
                    res = _(obj).chain()
                            .keys()
                            .map((key) -> _.map(obj[key], f(key)))
                            .flatten()
                    Fiber( ->
                        res.map((el) -> Datasets.insert el)
                    ).run()
            )
)

