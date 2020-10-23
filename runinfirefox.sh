#!/bin/sh
( sleep 2 ; firefox http://localhost:8000/$1.html ) &

python -m http.server
