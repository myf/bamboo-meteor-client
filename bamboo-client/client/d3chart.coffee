mock_element =
    name:"birthrate"
    groupVal:"sexywomen"
    groupKey:"attractiveness"
    datasetURL:"http://google.com"
    data:
        blonde:3
        brunette:2
        redhead:13

#it will take a dataset object and reder svg graph out of it
d3chart= (dataElement)->
    name = dataElement.name
    data = dataElement.data
    width = 200
    height = 200

    svg = d3.select('body')
            .append('svg:svg')
            .attr('width', width)
            .attr('height',height)
    svg.append('svg:rect')
        .attr('x',100)
        .attr('y',100)
        .attr('width',100)
        .attr('height',100)
    ###

    #domain is from zero to datamax
    #perhaps datamax of the same field? 
    #we want to compare across different graphs
    #
    #range is from zero to output max pixel
    #
    #ordinal scale
    x_scale = d3.scale.linear()
                .domain([])
                .range([])

    y_scale = d3.scale.linear()
                .domain([])
                .range([])

    x_axis = d3.svg.axis
                .scale(x_scale)
                .orient('bottom')
                .ticks(5)

    y_axis = d3.svg.axis
                .scale(y_scale)
                .orient('left')
                .ticks(5)

    #HOW TO USE RECT???

    svg.selectAll('rect')
        .data()
        .enter()
        .append('rect')
        .attr('y')
        .attr('width')
        .attr('height')
    ###




                


