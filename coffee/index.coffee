width = 960
height=800
options =
	select : [{name:"Choose Map",value:'na'},{name:'Countries invaded by Britain',value:'brit'}]
template = Mustache.compile """
<select id="selectMap" class="mapSelect">
{{#select}}
<option value="{{value}}">{{name}}</option>
{{/select}}
</select>

"""
notInvaded=[
	'AND'
	'BLR'
	'BOL'
	'BDI'
	'CAF'
	'TCD'
	'COG'
	'GTM'
	'CIV'
	'KGZ'
	'LIE'
	'LUX'
	'MLI'
	'MHL'
	'MCO'
	'MNG'
	'PRY'
	'STP'
	'SWE'
	'TJK'
	'UZB'
	'VAT'
]
makeClass = (d)->
	switch $('#selectMap').val()
		when 'brit'
			if d.properties.sov in notInvaded
				'notInvaded'
			else
				'invaded'
		else
			'norm'
$("#selector").html template(options)
svg = d3.select("#maincontent").append("svg").attr("width", width).attr("height", height)
path = d3.geo.path().projection(null)
topo=undefined 
result = ()->
	svg.append("g").attr("transform","scale(1)translate(1,1)").attr("class", "city")
	.selectAll("path")
	.data(topojson.feature(topo, topo.objects.world).features)
	.enter().append("path").attr("d", path).attr("class",makeClass).append("title").text((d)->
		d.properties.name
	)
	true
d3.json "json/world.json",(e,r)->
	topo=r
	result()
	
$('#selectMap').on 'change', result

