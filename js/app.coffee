jQuery ->
	
	class Visitor extends Backbone.Model
	
	class Visitors extends Backbone.Collection
		model: Visitor
	
	class VisitorsView extends Backbone.View

		initialize: ->
			_.bindAll @

			@parentView = @options.parentView
			@cities = @parentView.map.append("svg:g").attr("id", "cities")

			@collection = new Visitors
			@collection.reset @options.collectionData

			@render()
		
		render: ->
			data = @collection.toJSON()
			r = d3.scale.linear().domain([0,1]).range([5,10])
			projection = @parentView.projection
			
			@cities.selectAll("circle")
				.data( data )
				.enter().append("svg:circle")
				.attr("r", (d) -> Math.sqrt d.value )
				.attr("cx", (d) -> projection([d.latitude, d.longitude])[0] )
				.attr("cy", (d) -> projection([d.latitude, d.longitude])[1] )
			@
		


	class WorldView extends Backbone.View
		el: $ '#map'

		geojson_paths: world_countries

		initialize: ->
			_.bindAll @

			@viewLayers = []

			@projection = d3.geo.mercator().scale(1).translate([0, 0])
			@path = d3.geo.path().projection(@projection)

			@map = d3.select("#" + $(@el).attr('id')).append("svg:svg")
			@world = @map.append("svg:g").attr("id", "world")

			@scaleWorldMap()

			@render()
		
		render: -> 
			features = @world.selectAll('path');
			features.data(@geojson_paths.features)
			    .enter().append('svg:path')
			      .attr('id', (d) -> d.id )
			      .attr('d', @path)
			    .append('svg:title')
			      .text((d) -> d.properties.name )
			@
		
		addViewLayer: (data, viewClassString) ->
			view = new viewClassString collectionData:data, parentView:@
			@viewLayers.push view
		
		scaleWorldMap: ->
			width = $(@el).width()
			height = $(@el).height()

			bounds0 = d3.geo.bounds(@geojson_paths)
			bounds = bounds0.map(@projection)
			xscale = width/Math.abs(bounds[1][0] - bounds[0][0])
			yscale = height/Math.abs(bounds[1][1] - bounds[0][1])
			scale = Math.min(xscale, yscale)

			@projection.scale(scale)
			@projection.translate(@projection([-bounds0[0][0], -bounds0[1][1]]))
		

	#dont let it go to the backend
	Backbone.sync = (method, model, success, error) ->
		success()

	worldMap = new WorldView
	worldMap.addViewLayer(cities, VisitorsView)
