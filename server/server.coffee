root = global ? window
require = __meteor_bootstrap__.require
request = require 'request'
#bambooURL = 'http://localhost:8080'
#bambooURL = 'http://bamboo.modilabs.org/'
bambooURL = 'http://bamboo.io/'
datasetsURL = bambooURL + '/datasets'
summaryURLf = (id,group) -> datasetsURL + '/' + id + '/summary' + if group then '?group=' + group else ''
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
                try
                    request post_options, (e, b, response) ->
                        Fiber(->
                            try
                                unless Datasets.findOne({url: url})
                                    Datasets.insert
                                        bambooID: JSON.parse(response).id
                                        url: url
                                        cached_at: Date.now()
                                        #Meteor.setTimeout (->
                                        #Meteor.call('summarize_by_group', [url, ''])
                                    Meteor.call('insert_schema', url)
                                        #), 1000
                            catch error
                        ).run()
                catch error
                    console.log error

    insert_schema: (datasetURL) ->
        dataset = Datasets.findOne(url: datasetURL)
        if !(dataset)
            console.log "no dataset yet, get your schema dataset first"
        else
            datasetID = dataset._id
            bambooID = dataset.bambooID
            #TODO: not sure about the updated time or created time
            if Schemas.findOne(datasetID: datasetID)
                console.log("schema with datasetID " + datasetID + " and bambooID " + bambooID + " is already cached")
            else
                try
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
                catch error
                    console.log error

    summarize_by_group: (obj) ->
        # tease out individual summary objects from bamboo output + store
        [datasetURL, groupkey] = obj
        dataset =  Datasets.findOne(url: datasetURL)
        #check if dataset valid
        if !(dataset)
            console.log "no dataset yet, get your summary dataset first"
        else
            datasetID = dataset._id
            bambooID = dataset.bambooID
            if Summaries.findOne(datasetID: datasetID,groupKey: groupkey)
                console.log("summary with datasetID "+datasetID+" and groupkey "+groupkey+" is already cached")
            else
                try
                    request.get(summaryURLf(bambooID, groupkey), (error,body,response) -> 
                        if error
                            console.log error
                        else
                            obj = JSON.parse(response)
                            if groupkey is ""
                                for field of obj 
                                    res=
                                        groupKey: groupkey
                                        groupVal: groupkey
                                        data: obj[field]["summary"]
                                        name:field
                                        datasetID: datasetID
                                        datasetURL: datasetURL
                                    Fiber( -> Summaries.insert res).run()
                            else
                                if obj["error"]
                                    console.log "error on group_by: "+obj['error']
                                else
                                    for group_by of obj
                                        for groupval of obj[group_by]
                                            for field of obj[group_by][groupval]
                                                res=
                                                    groupKey: groupkey
                                                    groupVal: groupval
                                                    data: obj[group_by][groupval][field]["summary"]
                                                    name:field
                                                    datasetID: datasetID
                                                    datasetURL: datasetURL
                                                Fiber( -> Summaries.insert res).run()
                    )
                catch error
                    console.log error
)
