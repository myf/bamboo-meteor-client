mock_element =
    name:"birthrate"
    groupVal:"sexywomen"
    groupKey:"attractiveness"
    data:
        blonde:3
        brunette:2
        redhead:13

#it will take a dataset object and reder svg graph out of it
d3chart: (dataElement)->
    name = dataElement.name
    data = dataElement.data
    width = 200
    height = 200

    svg = d3.select('body')
            .append('svg:svg')
            .append('width', width)
            .append('height',height)

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


                


