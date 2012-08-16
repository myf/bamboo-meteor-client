nvd3BarChart = (dataElement, div, min, max) ->
    count = 0
    str = "Bar Chart of " + dataElement.name
    arr = []
    for key of dataElement.data
        arr.push( { label : key, value : dataElement.data[key]})
        count += dataElement.data[key]
    dataset = [ { key : str, values: arr }]
    
    if (dataElement.groupKey is "") and (dataElement.groupVal is "")
        title = dataElement.name + " (" + count + ")"
    else
        title = dataElement.groupKey + " : " + dataElement.groupVal + " (" + count + ")"

    nv.addGraph( () ->
        width = 300
        height = 250
        chart = nv.models.discreteBarChart()
            .width(width)
            .height(height)
            #change the margin
            .margin({top:30, right:10, bottom:50, left:60})
            .x( (d)->
                d.label
            )
            .y( (d)->
                d.value
            )
            .rotateLabels(-45)
            .staggerLabels(true)
            .tooltips(true)
            .showValues(false)
            .forceY([min, max])

        svg = d3.select(div)
            .append("svg")
            .attr("class", "barChartSVG")

        svg.append("text")
            .text(title)
            .attr("x", 130)
            .attr("y", 12)
            .attr("class", "boxplot_title")
            .attr("fill", "black")

        svg.datum(dataset)
            .transition().duration(500)
            .call(chart)
        #TODO:what does this line do?
        nv.utils.windowResize(chart.update)

        return chart

        return
    )
