@swarm_controller = ($scope) ->
  $scope.oil_radius     = 65
  $scope.oil_volume     = 550
  $scope.remove_time    = 10
  $scope.skimmers_count = 17

  $scope.spots_count    = 2 

  $scope.count_agents = () ->
    console.log 'change'    

  $scope.start_animation = ($event) ->
    $('.step_1').hide()
    $('.step_2').show()
    $event.preventDefault()

    paper.install window
    canvas = document.getElementById("paperCanvas")
    paper.setup canvas
    size = new Size(800, 800)
    view.viewSize = size
    tool = new Tool()

    paper.Item.inject
      myRotate: (angle) ->
        @my_rotation += angle
        @rotate angle

      my_rotation: 0
       
    skimmerOptions = 
      startX: 100
      startY: 500
      pathStartX: 580
      pathStartY: 250

    values =
      paths: $scope.spots_count
      minPoints: 5
      maxPoints: 15
      minRadius: 130
      maxRadius: 400

    hitOptions =
      segments: true
      stroke: true
      fill: true
      tolerance: 5

    createPaths = ->
      radiusDelta = values.maxRadius - values.minRadius
      pointsDelta = values.maxPoints - values.minPoints

      for i in  [0..values.paths-1]
        radius = values.minRadius + Math.random() * radiusDelta
        radius = values.maxRadius-50 if i is 0
        points = values.minPoints + Math.floor(Math.random() * pointsDelta)
        path = createBlob(view.size.multiply(Point.random()), radius, points)
        lightness = (Math.random() - 0.5) * 0.4 + 0.4
        hue = Math.random() * 360
        path.position = paper.view.center
        path.fillColor = "#000"
        path.strokeColor = "black"
        path.opacity = 0.4

    createBlob = (center, maxRadius, points) ->
      path = new Path()
      path.closed = true

      for i in [0..points-1]
        delta = new Point(
          length: (maxRadius * 0.5) + (Math.random() * maxRadius * 0.5)
          angle: (360 / points) * i
        )
        path.add(center.add(delta))

      path.smooth()
      path

    window.oilLayer = new Layer();

    createBase = () ->
      base = new Path.Rectangle 
        point: {x:700, y:20}
        size: [50,10]
        fillColor: 'blue'  
    

    createPaths()
    createBase()


    window.skimmersDrawLayer = new Layer();
    window.skimmersLayer = new Layer();

    window.sectorsLayer = new Layer();

    circle_path = new Path.Circle {
        center: view.center
        radius: 120
        strokeColor: 'red'
    }
    circle_path.strokeWidth = 5
    outer_circle_path = new Path.Circle {
        center: view.center
        radius: 385
        strokeColor: 'red'
    }
    outer_circle_path.strokeWidth = 5
    horizon_line = new Path(
      segments: [[15, view.size._height/2],[view.size._width - 15, view.size._height/2]]
      strokeColor: "red"
      strokeWidth: 2
    )
    vertical_line = new Path(
      segments: [[view.size._width/2, 15],[view.size._width/2, view.size._height - 15]]
      strokeColor: "red"
      strokeWidth: 2
    )
    vertical_line_1 = new Path(
      segments: [[486, 318],[667, 125]]
      strokeColor: "blue"
      strokeWidth: 2
    )

    vertical_line_5 = new Path(
      segments: [[486,318],[667,100]]
      strokeCOlor: "green"
      strokeWidth: 1
    )

    vertical_line_2 = new Path(
      segments: [[486, 484],[667, 681]]
      strokeColor: "blue"
      strokeWidth: 2
    )
    vertical_line_3 = new Path(
      segments: [[313, 484],[138, 681]]
      strokeColor: "red"
      strokeWidth: 2
    )
    vertical_line_4 = new Path(
      segments: [[313,318],[136,122]]
      strokeColor: "red"
      strokeWidth: 2
    )

    skimmersLayer.activate()

    window.skimmer = new Path.Rectangle
      point: {y: skimmerOptions.startY, x: skimmerOptions.startX}
      size: [15, 15]
      strokeColor: 'green'
      fillColor: 'green'

    skimmersDrawLayer.activate()

    # window.skimmer_path = new Path
    #   segments: [{y: 300, x: 500}]
    #   strokeColor: "white"
    #   strokeWidth: 15
    #   opacity: 0.6

#####################################################################################

    center_of_movenment =
      radius: 100
      center: new Point(skimmerOptions.pathStartX, skimmerOptions.pathStartY)
    
    minRadius = 500
    maxRadius = 600
    degree = 90
    divDegree = 0.5    
    dx = 0
    dy = 0    
    radiusMovement = 1    

    change      = 100
    decrease    = false
    create_path = true

    angle = 0

    view.onFrame = (event) ->
        
        #смещение агента###################################
      
      if decrease is true
        change -= 1
        radiusMovement-=1
      else
        change += 1
        radiusMovement+=1
      
        ###################################################
      
        #проверка выхода за Границу########################
      
      if radiusMovement >= maxRadius
        decrease = true
        create_path = true
        degree+= divDegree
        console.log(degree)
        console.log(x)
        console.log(y)       
 
      if radiusMovement <= minRadius
        decrease = false
        create_path = true
        console.log(x)
        console.log(y)

    #  if change >= center_of_movenment.radius
    #    decrease    = true
    #    create_path = true
      
    #  if change <= -center_of_movenment.radius
    #    decrease    = false
    #    create_path = true
    #    degree += divDegree 
    #    console.log(degree)

        ###################################################

 #     x = center_of_movenment.center.x + change
 #
 #     y_change = change #(change*change) / 100
 #
 #     y = center_of_movenment.center.y - y_change
  
      radian = ((2*3.14)/360)*degree     

      dx = radiusMovement*Math.sin(radian)
      dy = radiusMovement*Math.cos(radian)

      x = center_of_movenment.center.x + dx
      y = center_of_movenment.center.y + dy

     # console.log(x)

      skimmer.position = new Point ({y: y, x: x})
      
      if create_path is true
        if window.skimmer_path
          window.skimmer_path.simplify 30
          window.skimmer_path.smooth
        window.skimmer_path = new Path
          segments: [{y: y, x: x}]
          strokeColor: "white"
          strokeWidth: 15
          opacity: 0.2
        create_path = false
      else
        window.skimmer_path.add skimmer.position


#######################################################################################################
    # draw_path = undefined
    # segment = undefined
    # path = undefined
    # movePath = false

    # tool.onMouseDown = (event) ->
    #   draw_path.selected = false if draw_path      
    #   draw_path = new Path(
    #     segments: [event.point]
    #     strokeColor: "white"
    #     strokeWidth: 1
    #     fullySelected: false
    #     #opacity: 0.5
    #   )

      # segment = path = null
      # hitResult = project.hitTest(event.point, hitOptions)
      # return  unless hitResult
      # if event.modifiers.shift
      #   hitResult.segment.remove()  if hitResult.type is "segment"
      #   return
      # if hitResult
      #   path = hitResult.item
      #   if hitResult.type is "segment"
      #     segment = hitResult.segment
      #   else if hitResult.type is "stroke"
      #     location = hitResult.location
      #     segment = path.insert(location.index + 1, event.point)
      #     path.smooth()
      # movePath = hitResult.type is "fill"
      # project.activeLayer.addChild hitResult.item  if movePath

    # tool.onMouseDrag = (event) ->
    #   draw_path.add event.point
    #   if segment
    #     segment.point = event.point
    #     path.smooth()
    #   path.position += event.delta  if movePath

    # tool.onMouseUp = (event) ->
    #   window.ppp = event.point
    #   draw_path.simplify 10      
    #   #draw_path.fullySelected = true
    tool.onMouseMove = (event) ->
      project.activeLayer.selected = false
      for layer in project.layers
        layer.selected = false
      event.item.selected = true  if event.item

    view.draw()

    true

  $scope.show_parameters = ($event) ->
    $('.step_2').hide()
    $('.step_1').show()
    $event.preventDefault()
