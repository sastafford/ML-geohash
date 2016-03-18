import module namespace geojson = "http://marklogic.com/geospatial/geojson" at "/MarkLogic/geospatial/geojson.xqy";
declare option xdmp:coordinate-system "wgs84/double";

let $geohash-precision := 6
let $input-poly := xdmp:get-request-body()

let $poly := try {
  cts:polygon($input-poly)
}
catch($err) {
  let $vertices :=
  for $item in $input-poly/*
  return cts:point($item/lat, $item/lng)
        
  return cts:polygon($vertices)
}

let $boundary-hashes := geo:geohash-encode($poly,$geohash-precision,("geohashes=boundary","box-percent=0"))
let $interior-hashes := geo:geohash-encode($poly,$geohash-precision,("geohashes=interior","box-percent=0"))

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

let $center := geo:approx-center($poly)

let $output := object-node {
        "polygon" : object-node { "type":"Feature", "geometry":geojson:to-geojson($poly) },
        "polygonWkt" : geo:to-wkt($poly),
        "boundary" : array-node { $boundary-boxes },
        "interior" : array-node { $interior-boxes },
        "center" : object-node { "lat":cts:point-latitude($center), "lng":cts:point-longitude($center) }
        }

return $output

