root = global ? window
bambooUrl = "/"
observationsUrl = bambooUrl + "datasets"

constants =
    #defaultURL : 'http://formhub.org/education/forms/schooling_status_format_18Nov11/data.csv'
    defaultURL : 'https://www.dropbox.com/s/0m8smn04oti92gr/sample_dataset_school_survey.csv?dl=1'
    #defaultURL : 'http://localhost:8000/education/forms/schooling_status_format_18Nov11/data.csv'
    #defaultURL : 'http://formhub.org/mberg/forms/good_eats/data.csv'


############ UI LOGIC ############################
if root.Meteor.is_client
    root.Template.navbar.events = "click button": ->
        url = $('#datasource-url').val()
        Session.set('currentDatasetURL', url)
        #TODO: put the following in a Meteor.subscribe section?
        #TODO: eliminates null url from being registered into db
        if !Datasets.findOne(url: url)
            console.log "caching server side.."
            Meteor.call('register_dataset', url)
        else
            console.log "already cached server side.."

    root.Template.control.events = "click button": ->
        Meteor.call("charting")

    root.Template.control.groups = ->
        names = Session.get('fields')
        #TODO: filter ungroupable stuff out of fields

    root.Template.group.events = "click button": ->
        group = ""+this
        Session.set('currentGroup',group)
        url = Session.get('currentDatasetURL')
        Meteor.call("summarize_by_group",[url,group])

    root.Template.maincontent.fields = ->
        Meteor.call("get_fields",Session.get('currentDatasetURL'))
        fields = Session.get('fields')
        Meteor.call('generate_visible_fields', fields)
        visible_fields = Session.get('visible_fields')
        console.log visible_fields
        display = []
        for item in visible_fields
            display.push(item['field'])
        display


    #getting url
    root.Template.navbar.default =Session.get('currentDatasetURL') ? constants.defaultURL

        
       
    

############# UI LIB #############################


Meteor.methods(
    generate_visible_fields: (fields)->
        group_by = Session.get('currentGroup')
        console.log typeof group_by
        visible_fields = []
        for item in fields
            obj=
                field: item
                group_by: group_by
            visible_fields.push(obj)
        Session.set("visible_fields",visible_fields)

    make_single_chart: (obj) ->
        [div, dataElement] = obj
        #dataElement.titleName = makeTitle(dataElement.name)
        dataElement.titleName = dataElement["groupVal"]
        data = dataElement.data
        dataSize = _.size(data)

        unless (dataSize is 0) or (dataElement.name.charAt(0) is '_')
            keyValSeparated =
                x: _.keys(data)
                y: _.values(data)
            if typeof keyValSeparated.y[0] is "number"
                #if number make pure histogram
                #histogram logic
                gg.graph(keyValSeparated).layer(gg.layer.bar().map('x','x').map('y','y')).opts(
                    width: Math.min(dataSize*60 + 100, 220)
                    height: "270"
                    "padding-right": "50"
                    title: dataElement.titleName
                    "title-size":12
                    "legend-position":"bottom"
                ).render(div)

    clear_graphs: ->
        graph_divs = $('.gg_graph')
        for item in graph_divs
            $(item).empty()

    charting: ->
        Meteor.call('clear_graphs')
        url = Session.get("currentDatasetURL")
        group = Session.get("currentGroup") ? "" #some fallback
        item_list = Summaries.find(datasetURL:url, groupKey:group).fetch()
        list = Meteor.call('grouping', item_list)
        $.each(list, (key,value)->
            for item in value
                div = "#"+item["name"]+".gg"
                Meteor.call("make_single_chart",[div,item])
        )
    field_charting:(field) ->
        Meteor.call('clear_graphs')
        url = Session.get("currentDatasetURL")
        group = Session.get("currentGroup") ? "" #some fallback
        item_list = Summaries.find
            datasetURL:url
            groupKey:group
        .fetch()
        list = Meteor.call('grouping', item_list)
        $.each(list, (key,value)->
            for item in value
                if item['name']==field
                    div = "#"+field+".gg"
                    Meteor.call("make_single_chart",[div,item])
        )

    grouping: (list) ->
        fin = {}
        #group_list = _list.pluck("groupVal")
        #group_list = (list.map (x)->x.groupVal).unique()
        group_list = list.map (x)->x.groupVal
        for item in group_list
            fin[item]=[]
        for item in list
           group = item['groupVal']
           fin[group].push(item)
        fin

    get_fields:(url)->
        fin = []
        dataset = Schemas.findOne
            datasetURL: url
        if dataset
            console.log "data found: "
            names = []
            schema = dataset['schema']
            for name of schema
                names.push(name)
            #fields is an array []
            fin = names
        else
            dataset = Datasets.findOne(url: url)
            if (!dataset)
                Meteor.call('register_dataset', url)
        Session.set('fields', fin)
    #testing only
    alert: (something)->
        display = something ? "here here"
        alert display

)
Array::unique = ->
    output = {}
    output[@[key]] = @[key] for key in [0...@length]
    value for key, value of output
