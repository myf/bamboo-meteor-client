root = global ? window

if root.Meteor.is_client
    root.Template.navbar.foo = ->
        "Summarize!"
    
    root.Template.navbar.events = "click button": ->
        console.log($('#datasource-url').val())

    makeTitle = (slug) ->
        words = (word.charAt(0).ToUpperCase() + word.slice(1) for word in slug.split('_'))
        words.join(' ')
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


