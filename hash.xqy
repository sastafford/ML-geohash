let $input-poly := xdmp:get-request-body()

let $vertices :=
for $item in $input-poly/*
return cts:point($item/lat, $item/lng)

let $poly := cts:polygon($vertices)

let $boundary-hashes := geo:geohash-encode($poly,6,("geohashes=boundary","box-percent=0"))
let $interior-hashes := geo:geohash-encode($poly,6,("geohashes=interior","box-percent=0"))

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

let $output := object-node {
        "boundary" : array-node { $boundary-boxes },
        "interior" : array-node { $interior-boxes }
        }

return $output

