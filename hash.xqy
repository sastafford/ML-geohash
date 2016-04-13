import module namespace geojson = "http://marklogic.com/geospatial/geojson" at "/MarkLogic/geospatial/geojson.xqy";
declare option xdmp:coordinate-system "wgs84/double";

let $input := xdmp:get-request-body()

let $region := $input/region
let $geohash-precision := $input/precision

let $boundary-hashes := geo:geohash-encode($region,$geohash-precision,("geohashes=boundary","box-percent=0","units=meters"))
let $interior-hashes := geo:geohash-encode($region,$geohash-precision,("geohashes=interior","box-percent=0","units=meters"))

let $boundary-boxes :=
for $hash in $boundary-hashes
let $box := geo:geohash-decode($hash)
return object-node {
        "hash" : $hash,
        "north" : cts:box-north($box),
        "south" : cts:box-south($box),
        "east" : cts:box-east($box),
        "west" : cts:box-west($box)
        }
let $interior-boxes :=
for $hash in $interior-hashes
let $box := geo:geohash-decode($hash)
return object-node {
        "hash" : $hash,
        "north" : cts:box-north($box),
        "south" : cts:box-south($box),
        "east" : cts:box-east($box),
        "west" : cts:box-west($box)
        }


let $str := try {
  geo:to-wkt($region)
} catch($e) {
  fn:string($region)        
}

let $center := try {
  geo:approx-center($region)
} catch($e) {
  cts:point($region)
}

let $output := object-node {
        "polygonWkt" : $str,
        "boundary" : array-node { $boundary-boxes },
        "interior" : array-node { $interior-boxes },
        "center" : object-node { "lat":cts:point-latitude($center), "lng":cts:point-longitude($center) }
        }

return try {
  let $geom := geojson:to-geojson($region)
  let $node := object-node {"feature" : object-node { "type":"Feature", "geometry": $geom} }
  return xdmp:node-insert-child($output, $node/feature)      
} catch($e) {
  $output
}



