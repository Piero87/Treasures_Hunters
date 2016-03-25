#
# A marker class
#
define ["leaflet"], (Leaflet) ->

	class Marker
		constructor: (map_view, type, uid, name, team, level, lat , lng, icon, map_obj) ->
			
			
			@clicked = false
			
			@map = map_view
			@uid = uid
			@name = name
			@team = team
			@level = level
			@lat = lat
			@lng = lng
			@markericon = icon
			@map_obj = map_obj
			
			latlng = new Leaflet.LatLng(lat, lng)
			
			# Custom buster marker popup based on team	
			@customOptionsRed =
				'className': 'custom-red'
			
			@customOptionsBlue =
				'className': 'custom-blue'
			
			t = type
			switch t
				when "buster" # Buster
					if @team == "red"
						@marker = new Leaflet.Marker(latlng, {icon: @markericon}).bindPopup(@name, @customOptionsRed).addTo(@map)
					else if @team == "blue"
						@marker = new Leaflet.Marker(latlng, {icon: @markericon}).bindPopup(@name, @customOptionsBlue).addTo(@map)
				
				when "ghost" # Ghost
					# Check the level and the mood of the ghost
					@marker = new Leaflet.Marker(latlng, {icon: @markericon})
					if level == 3 
						@marker.on 'click', @onClick
					@marker.addTo(@map)
					@circle = new Leaflet.Circle(latlng, 3*level, {color: 'white', fillColor: '#fff', fillOpacity: 0.5}).addTo(@map)
				
				when "treasure" # Treasure
					@marker = new Leaflet.Marker(latlng, {icon: @markericon}).addTo(@map)
					@circle = new Leaflet.Circle(latlng, 6).addTo(@map)
				
				when "trap" # Trap
					@marker = new Leaflet.Marker(latlng, {icon: @markericon}).addTo(@map)
					@circle = new Leaflet.Circle(latlng, 2).addTo(@map)
					
		# Update buster marker position with the given latLng coordinates
		update: (lat, lng) ->
			# Update the position
			latlng = new Leaflet.LatLng(lat, lng)
			@marker.setLatLng(latlng)
			@circle.setLatLng(latlng)
			console.log(@map_obj)
			console.log("cacca")
			
		#Set icon
		setMarkerIcon: (icon) ->
			@marker.setIcon(icon)
	
		# Remove the marker from the map
		remove: () ->
			@map.removeLayer(@marker)
			@map.removeLayer(@circle)
			
		# onClick function. It activate the ghost manual mode for admin
		onClick: (evt) ->
			if (@clicked != true)
				@clicked = true
				@map_obj.updateGhostMarkers(@uid, 3, 1, @lat, @lng)
				@map_obj.ghostManualMode(@uid) 
			else
				@clicked = false
				@map_obj.updateGhostMarkers(@uid, 3, 0, @lat, @lng)
				@map_obj.ghostNormalMode(@uid)
			
	return Marker