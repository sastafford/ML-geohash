# ML-geohash
A demo app showing off MarkLogic's new geohash functions.

## Setup

1. Clone the repository to a local directory.
2. Set up an HTTP App Server in MarkLogic. Set the root to the directory from step 1, and set the port to whatever port number you would like (say, 1337). (See https://docs.marklogic.com/guide/getting-started/xquery#id_15787 for detailed instructions.)
3. Navigate to http://localhost:1337/geohash.html (substituting your hostname and port number).
4. Draw some polygons, and see their geohashes! Refresh to clear.

## Features

* Draw a polygon on the map to see its geohashes.
* Input a polygon in WKT format and click "GeoHash" to see the polygon and its geohashes.
* Click "Show/Hide Labels" to show or hide the labels for the geohash boxes (if there are lots of hashes, you might want to hide the labels since they can cause lots of lag).
* Click "Show/Hide Geodesic Arcs" to show the edges of the polygon as geodesic arcs (as opposed to rhumb lines -- this display mode is more accurate for long arcs).
* To view geohashes at other levels of precision, edit hash.xqy and change the line
```xquery
let $geohash-precision := 6
```
to the desired level of precision (1 through 11).

## Etc.

Feel free to fork or send a pull request!

maplabel.js is copyright Google, Inc. (https://github.com/googlemaps/js-map-label) and is redistributed here under the terms of the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0).
