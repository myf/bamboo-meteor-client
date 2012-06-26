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
    ###
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
        fields = Session.get('fields')
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
        display = []
        for item in visible_fields
            display.push(item['field'])
        display


    ###
    
    ###
    ##getting url
    root.Template.url-entry.default =Session.get('currentDatasetURL') ? constants.defaultURL
    ###


    
    #every function can be accessed by the template it is defined under
    root.Template.url_entry.events = "click .btn": ->
        url = $('#dataSourceURL').val()
        Session.set('currentDatasetURL', url)
        #Meteor.call('chosen')
        if !Datasets.findOne(url: url)
            console.log "caching server side.."
            Meteor.call('register_dataset', url)
            Meteor.call('summarize_by_group',[url,''])
        else
            console.log "already cached server side.."
    
    root.Template.url_entry.exist = ->
        Session.get('currentDatasetURL')

    root.Template.control_panel.show = ->
        #if there is currentDatasetURL in session-> show
        Session.get('currentDatasetURL')

    #have to write this code to make chosen recognized in jquery
    root.Template.control_panel.chosen= ->
        #Meteor.defer(-> $('.chosen').chosen())
        Meteor.defer(->
            Meteor.call('chosen')
        )

    root.Template.control_panel.fields= ->
        Meteor.call("get_fields",Session.get('currentDatasetURL'))
        fields = Session.get('fields')
        Meteor.call('generate_visible_fields', fields)
        visible_fields = Session.get('visible_fields')
        display = []
        for item in visible_fields
            display.push(item['field'])
        display

    root.Template.control_panel.groups= ->
        #call summarize_by_group
        fields = Session.get('fields')

    root.Template.control_panel.num_graph= ->
        20
    
    root.Template.control_panel.events= "click .btn": ->
        group = $('#group-by').val()
        view_field = $('#view').val()
        url = Session.get('currentDatasetURL')
        Meteor.call("summarize_by_group",[url,group])
        Session.set('currentGroup', group)
        Session.set('currentView', view_field)

    root.Template.graph.show=->
        url = Session.get('currentDatasetURL')
        group = Session.get('currentGroup')
        view = Session.get('currentView')
        url and view

    root.Template.graph.field =->
        div = Session.get('currentView')
    
    root.Template.graph.charting =->
        Meteor.defer(->
            Meteor.call('field_charting')
        )
    

    

############# UI LIB #############################


Meteor.methods(
    chosen: ->
            $(".chosen").chosen(
                no_results_text: "No Result Matched"
                allow_single_deselect: true
            )

    generate_visible_fields: (fields)->
        group_by = Session.get('currentGroup')
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
    d3testing: ->
        d3chart(mock_element)

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
    field_charting: ->
        Meteor.call('clear_graphs')
        url = Session.get("currentDatasetURL")
        group = Session.get("currentGroup") ? "" #some fallback
        field =Session.get("currentView")
        item_list = Summaries.find
            datasetURL:url
            groupKey:group
            name:field
        .fetch()
        div = "#"+field+".gg"
        for item in item_list
            Meteor.call("make_single_chart",[div,item])

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
