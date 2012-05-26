root = global ? window
bambooUrl = "/"
observationsUrl = bambooUrl + "datasets"

default_url = 'http://localhost:8000/education/forms/schooling_status_format_18Nov11/data.csv'

if root.Meteor.is_client
    root.Template.navbar.events = "click button": ->
        url = $('#datasource-url').val()
        dataset = Datasets.findOne(url: url)
        if !dataset
            console.log "caching server side.."
            Meteor.call('register_dataset', url)
        else
            console.log "already cached server side.."
        Session.set('currentDatasetURL', url)

    root.Template.maincontent.columns = ->
        url = Session.get('currentDatasetURL') ? default_url
        console.log url
        datacursor = Summaries.find(datasetSourceURL: url, groupKey: '', groupVal: '(ALL)')
        if datacursor.count()
            console.log "data found: "
            return _(datacursor.fetch()).pluck("name")
        else
            dataset = Datasets.findOne(url: url)
            if (!dataset)
                Meteor.call('register_dataset', url)
            console.log "nada"
            return ['Loading dataset...']
        
Meteor.methods(
    make_chart: (obj) ->
        [div, dataElement] = obj
        #dataElement.titleName = makeTitle(dataElement.name)
        dataElement.titleName = "testing"
        data = dataElement.data
        console.log data
        dataSize = _.size(data)

        unless (dataSize is 0) or (dataElement.name.charAt(0) is '_')
            keyValSeparated =
                x: _.keys(data)
                y: _.values(data)
            if typeof keyValSeparated.y[0] is "number"
                #if number make pure histogram
                #histogram logic
                gg.graph(keyValSeparated).layer(gg.layer.bar().map('x','x').map('y','y')).opts(
                    width: Math.min(dataSize*60 + 100, 550)
                    height: "270"
                    "padding-right": "50"
                    title: dataElement.titleName
                    "title-size":12
                    "legend-position":"bottom"
                ).render(div)

    charting: (url) ->
        item_list = Datasets.findOne({url:url}).summary["(ALL)"]
        for item in item_list
            item_name = item["name"]
            div = "#"+item["name"]+".gg"
            Meteor.call("make_chart",[div,item])

)
