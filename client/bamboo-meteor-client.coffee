root = global ? window

if root.Meteor.is_client
    root.Template.navbar.foo = ->
        "Summarize!"
    root.Template.maincontent.response = "(placeholder)"
    
    root.Template.navbar.events = "click button": ->
        console.log('client-side click')
        url = $('#datasource-url').val()
        Meteor.call('register_dataset', url)
        dataset = Datasets.find({url: url}).fetch()[0]

    $tabsUl = $('#tabs')
    $altTabsUl = $('#alt-tabs')
    $sideBySide = $('#side-by-side')
    $contentDiv = $('#content')
    $groupingSelect = $('#grouping-select')
    $histogramSelect = $('#histogram-select')
    $datasourceUrl = $('#datasource-url')
    clearPage = () ->
        _([$contentDiv, $tabsUl, $altTabsUl, $groupingSelect, $histogramSelect]).each((x) -> x.empty)
        _([$groupingSelect, $histogramSelect, $sideBySide]).each((x) -> x.unbind('change'))
    makePageShell = (groups, currentGroup) ->
        group2select = (groups, $select) ->
            $select.append('<option value="' + x + '">' + makeTitle(x) + '</option>')
        group2select(groups, $histogramSelect)


