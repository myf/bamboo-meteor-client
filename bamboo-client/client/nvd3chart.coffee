nvd3BarChart = (dataElement, div, min, max) ->
    count = 0
    str = "Bar Chart of " + dataElement.name
    arr = []
    for key of dataElement.data
        arr.push( { label : key, value : dataElement.data[key]})
        count += dataElement.data[key]
    dataset = [ { key : str, values: arr }]
    
    if (dataElement.groupKey is "") and (dataElement.groupVal is "")
        title = dataElement.name + "(" + count + ")"
    else
        title = dataElement.groupKey + " : " + dataElement.groupVal + "(" + count + ")"

    nv.addGraph( () ->
        width = 300
        height = 250
        chart = nv.models.discreteBarChart()
            .width(width)
            .height(height)
            .x( (d)->
                d.label
            )
            .y( (d)->
                d.value
            )
            .rotateLabels(-45)
            .staggerLabels(true)
            .tooltips(false)
            .showValues(true)
            .forceY([min, max])

        svg = d3.select(div)
            .append("svg")
            .attr("class", "barChartSVG")
           
        svg.append("text")
            .text(title)
            .attr("x", 100)
            .attr("y", 11)
            .attr("class", "boxplot_title")
            .attr("fill", "black")
        svg.datum(dataset)
            .transition().duration(500)
            .call(chart)

        nv.utils.windowResize(chart.update)

        return chart

        return
    )
