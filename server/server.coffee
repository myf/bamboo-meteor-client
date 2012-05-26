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
        unless Datasets.findOne({url: url}) 
            post_options =
                uri: datasetsURL
                method: 'POST'
                form: {url: url}
            request(post_options, (e, b, response) ->
                Fiber(->
                    Datasets.insert
                        bambooID: JSON.parse(response).id
                        url: url
                        cached_at: Date.now()
                ).run()
                summaryCallback = -> 
                    Meteor.call('summarize_by_group', [url: ''])
                setTimeout summaryCallback, 1000

            )
    summarize_by_group: (obj) ->
        # tease out individual data elements from bamboo output, and store away
        [datasetURL, groupkey] = obj
        dataset =  Datasets.findOne(url: datasetURL)
        dataset console.log "dataset not found" unless dataset
        return unless dataset
        # TODO: should we do a stricter check?
        if Summaries.findOne(datasetID: datasetID, groupKey: groupkey)
            console.log "already cached: group splits for " + groupkey + " on dataset " + datasetID
        else
            console.log "calculating: group splits for " + groupkey + " on dataset " + datasetID
            dataset = Datasets.findOne("_id": datasetID)
            bambooID = dataset.bambooID
            datasourceURL = dataset.url
            request.get(summaryURLf(bambooID, groupkey), (e, b, response) ->
                    obj = JSON.parse(response) # a dict split by dict_val
                    dataElToDbObj = (groupval) -> (dataEl) ->
                            groupKey: groupkey
                            groupVal: groupval
                            data: dataEl.data
                            name: dataEl.name
                            datasetID: datasetID
                            datasetSourceURL: datasourceURL
                    res = _(obj).chain()
                            .keys()
                            .map((key) -> _.map(obj[key], dataElToDbObj(key)))
                            .flatten()
                    Fiber( -> res.each((el) -> Summaries.insert el))
                        .run()
            )
)
