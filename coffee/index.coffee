width = 960
height=800
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
#projection = d3.geo.albers().scale(20000).center([0, 42.2]).rotate([71.8,0])
path = d3.geo.path().projection(null)
dat=[]
getValue = (value)->
	return 0 unless value
	startVal=value[$('#selStat').val()][$('#selStart').val()]
	return 0 if startVal == 0
	endVal = value[$('#selStat').val()][$('#selEnd').val()]
	((endVal-startVal)/startVal)*100

makeScale=(data)->
	values = for key,value of data
		getValue(value)
	values = values
	values.sort d3.ascending
	cutoff = d3.bisectLeft(values,0)
	nQuant = d3.scale.quantile()
	nQuant.domain values.slice(0,cutoff)
	nQuant.range [8..1]
	pQuant = d3.scale.quantile()
	pQuant.domain values.slice(cutoff)
	pQuant.range [1..8]
	(d)->
		switch
			when d>0 then "Blues q#{pQuant(d)}-9"
			when d<0 then "Reds q#{nQuant(d)}-9"
			else ""

result = (err,[topo,dem])->
	dat=[topo,dem]
	scale = makeScale(dem)
	for key, value of dem
		dem[key.toUpperCase()]=value
	svg.append("g").attr("transform","scale(1)translate(1,1)").attr("class", "city")
	.selectAll("path")
	.data(topojson.feature(topo, topo.objects.towns).features)
	.enter().append("path")
	.attr("class", (d) ->
		console.log d
		"#{scale(getValue(dem[d.properties.id]))}"
	).attr("d", path).append("title").text((d)->
		"#{dem[d.properties.id].name} is #{getValue(dem[d.properties.id]).toFixed(2)}%"
	)
	true
queue().defer(d3.json,"json/ma.json").defer(d3.json,"json/demographics.json").awaitAll(result)
$('.mapSelect').on 'change', ()->
	result undefined,dat