root = global ? window
require = __meteor_bootstrap__.require
request = require 'request'
#bambooURL = 'http://localhost:8080'
#bambooURL = 'http://bamboo.modilabs.org/'
#bambooURL = 'http://bamboo.io/'
bambooURL = 'http://starscream.modilabs.org:8080/'
datasetsURL = bambooURL + '/datasets'
summaryURLf = (id,group) -> datasetsURL + '/' + id + '/summary' +
    if group then '?group=' + group else ''

schemaURLf = (id) -> datasetsURL + '/' + id + '/info'

#Note: methods can live anywhere, regardless of server or client
Meteor.methods(
    register_dataset: (url) ->
        if url is null
            console.log "null url! discard!"
        else
            console.log "server received url " + url
            unless Datasets.findOne({url: url})
                post_options =
                    uri: datasetsURL
                    method: 'POST'
                    form: {url: url}
                request post_options, (e, b, response) ->
                    Fiber(->
                        unless Datasets.findOne({url: url})
                            Datasets.insert
                                bambooID: JSON.parse(response).id
                                url: url
                                cached_at: Date.now()
                            Meteor.call('insert_schema', url)
                    ).run()

    insert_schema: (datasetURL) ->
        dataset = Datasets.findOne(url: datasetURL)
        if !(dataset)
            console.log "no dataset yet, get your schema dataset first"
        else
            datasetID = dataset._id
            bambooID = dataset.bambooID

            # TODO: not sure about the updated time or created time
            if Schemas.findOne(datasetID: datasetID)
                console.log("schema with datasetID " + datasetID +
                    " and bambooID " + bambooID + " is already cached")
            else
                request.get(schemaURLf(bambooID), (error, body, response) ->
                    if error
                        console.log error
                    else
                        obj = JSON.parse(response)
                        updateTime = obj['updated_at']
                        createTime = obj['created_at']
                        schema = obj['schema']
                        res =
                            updateTime : updateTime
                            createTime : createTime
                            schema : schema
                            datasetID : datasetID
                            datasetURL : datasetURL
                        Fiber( -> Schemas.insert res).run()
                )

    summarize_by_group: (obj) ->
        # tease out individual summary objects from bamboo output + store
        [datasetURL, groupkey] = obj
        dataset =  Datasets.findOne(url: datasetURL)
        # check if dataset valid
        if !(dataset)
            console.log datasetURL, groupkey
            console.log "no dataset yet, get your summary dataset first"
        else
            datasetID = dataset._id
            bambooID = dataset.bambooID
            if Summaries.findOne(datasetID: datasetID, groupKey: groupkey)
                console.log("summary with datasetID " + datasetID +
                    " and groupkey " + groupkey + " is already cached")
            else
                groupKey = groupkey
                request.get(summaryURLf(bambooID, groupkey), (error, body, response) ->
                    if error
                        console.log error
                    else
                        obj = JSON.parse(response)
                        if groupKey is ""
                            for field of obj
                                res=
                                    groupKey: groupKey
                                    groupVal: groupKey
                                    data: obj[field]["summary"]
                                    name:field
                                    datasetID: datasetID
                                    datasetURL: datasetURL
                                Fiber( -> Summaries.insert res).run()
                        else
                            if obj["error"]
                                console.log "error on group_by: "+obj['error']
                            else
                                for groupkey of obj
                                    for groupval of obj[groupkey]
                                        for field of obj[groupkey][groupval]
                                            res=
                                                groupKey: groupkey
                                                groupVal: groupval
                                                data: obj[groupkey][groupval][field]["summary"]
                                                name:field
                                                datasetID: datasetID
                                                datasetURL: datasetURL
                                            Fiber( -> Summaries.insert res).run()
                )
)
