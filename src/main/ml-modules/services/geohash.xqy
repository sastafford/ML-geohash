xquery version "1.0-ml";

module namespace resource = "http://marklogic.com/rest-api/resource/geohash";

import module namespace geojson = "http://marklogic.com/geospatial/geojson" at "/MarkLogic/geospatial/geojson.xqy";

declare option xdmp:coordinate-system "wgs84/double";

declare function get(
  $context as map:map,
  $params  as map:map
  ) as document-node()*
{
  xdmp:log("GET called")
};

declare function put(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
  ) as document-node()?
{
  xdmp:log("PUT called")
};

declare function post(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
  ) as document-node()*
{

  let $region := fn:string($input/node()/region)
  let $geohash-precision := $input/node()/precision

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

  let $str :=
    try {
      geo:to-wkt($region)
    } catch($e) {
      fn:string($region)
    }

  let $center :=
    try {
      geo:approx-center($region)
    } catch($e) {
      cts:point($region)
    }

  return
  document {
    try {
      let $geom := geojson:to-geojson(cts:region($region))
      return object-node {
        "feature": object-node {
          "type": "Feature",
          "geometry": $geom
        },
        "polygonWkt" : $str,
        "boundary" : array-node { $boundary-boxes },
        "interior" : array-node { $interior-boxes },
        "center" : object-node {
          "lat": cts:point-latitude($center),
          "lng": cts:point-longitude($center)
        }
      }
    } catch($e) {
      object-node {
        "polygonWkt" : $str,
        "boundary" : array-node { $boundary-boxes },
        "interior" : array-node { $interior-boxes },
        "center" : object-node {
          "lat": cts:point-latitude($center),
          "lng": cts:point-longitude($center)
        }
      }
    }
  }
};

declare function delete(
  $context as map:map,
  $params  as map:map
  ) as document-node()?
{
  xdmp:log("DELETE called")
};
