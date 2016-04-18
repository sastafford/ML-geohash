(:
Copyright 2016 MarkLogic Corporation 

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
:)

import module namespace geojson = "http://marklogic.com/geospatial/geojson" at "/MarkLogic/geospatial/geojson.xqy";
declare option xdmp:coordinate-system "wgs84/double";

let $input := xdmp:get-request-body()

let $region := fn:string($input/region)
let $geohash-precision := $input/precision

let $boundary-hashes := geo:geohash-encode($region,$geohash-precision,("geohashes=boundary","box-percent=0"))
let $interior-hashes := geo:geohash-encode($region,$geohash-precision,("geohashes=interior","box-percent=0"))

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

return try {
  let $geom := geojson:to-geojson(cts:region($region))
  return object-node {
    "feature": object-node { "type":"Feature", "geometry": $geom},
    "polygonWkt" : $str,
    "boundary" : array-node { $boundary-boxes },
    "interior" : array-node { $interior-boxes },
    "center" : object-node { "lat":cts:point-latitude($center), "lng":cts:point-longitude($center) }
  }     
} catch($e) {
  object-node {
    "polygonWkt" : $str,
    "boundary" : array-node { $boundary-boxes },
    "interior" : array-node { $interior-boxes },
    "center" : object-node { "lat":cts:point-latitude($center), "lng":cts:point-longitude($center) }
  }
}



