width = 960
height=700
options =
	stat : [{name:'Population',value:'pop'},{name:'House Holds',value:'hh'},{name:'Employment',value:'emp'}]
	start : ['2000','2010','2017','2020','2025','2030']
	end : ['2010','2017','2020','2025','2030','2035']
template = Mustache.compile """
<select id="selStat" class="mapSelect">
{{#stat}}
<option value="{{value}}">{{name}}</option>
{{/stat}}
</select>
<select id="selStart" class="mapSelect">
{{#start}}
<option value="{{.}}">{{.}}</option>
{{/start}}
</select>
<select id="selEnd" class="mapSelect">
{{#end}}
<option value="{{.}}">{{.}}</option>
{{/end}}
</select>
"""
$("#selector").html template(options)
svg = d3.select("#maincontent").append("svg").attr("width", width).attr("height", height)
projection = d3.geo.albers().scale(20000).center([0, 42.2]).rotate([71.8,0])
path = d3.geo.path().projection(projection)
dat=[]
getValue = (value)->
	return unless value
	startVal=value[$('#selStat').val()][$('#selStart').val()]
	return 0 if startVal == 0
	endVal = value[$('#selStat').val()][$('#selEnd').val()]
	((endVal-startVal)/startVal)*100
makeScale=(data)->
	quant = d3.scale.quantile()
	range = for key,value of data
		getValue(value)
	quant.domain(range)
	quant.range([0..8])
	quant

result = (err,[topo,dem])->
	dat=[topo,dem]
	scale = makeScale(dem)
	for key, value of dem
		dem[key.toUpperCase()]=value
	svg.append("g").attr("transform","scale(1)translate(1,1)").attr("class", "city")
	.attr("class","RdBu")
	.selectAll("path")
	.data(topojson.feature(topo, topo.objects.TOWNS).features)
	.enter().append("path")
	.attr("class", (d) ->
		  "q#{8-scale(getValue(dem[d.properties.name]))}-9 #{d.properties.name}"
	).attr("d", path).append("title").text((d)->
		"#{getValue(dem[d.properties.name]).toFixed(2)}%"
	)
	true
queue().defer(d3.json,"json/ma.topo.json").defer(d3.json,"json/demographics.json").awaitAll(result)
$('.mapSelect').on 'change', ()->
	result undefined,dat