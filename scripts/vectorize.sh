#!/usr/bin/env sh

INPUT=$1
FACTOR=$2

BASE=`basename $1 .tif`
SCALED=${BASE}.x${FACTOR}.tif
POLY=${BASE}.x${FACTOR}.shp
TILES=${BASE}.mbtiles

PROPERTY=$3
OUTPUT=$4

if [[ $# -le 3 ]] ; then
    echo "Usage: $0 inputfile.tif scaleFactor outputPropertyName outputDir"
    exit 0
fi

# Scale up raster values by factor of 100.  This takes us from ppl/(100m^2) to
# ppl/km^2.
# Also set nodata to 0 so that it'll get filtered out during polygonize.
echo "Scaling up ratser data x$FACTOR."
gdal_calc.py -A $INPUT --NoDataValue=0 --type=Float64 --calc="A * $FACTOR" --outfile=temp/$SCALED

# Polygonize
echo "Polygonizing."
gdal_polygonize.py -mask temp/$SCALED temp/$SCALED -f "ESRI Shapefile" temp/$POLY $PROPERTY $PROPERTY

# Convert to vector tiles.
echo "Generating vector tiles at $OUTPUT/$TILES."
`dirname $0`/tiles.js temp/$POLY $OUTPUT/$TILES

echo "Finished."
# TODO:
# Explore using zonal statistics to pull more accurate population value for each polygon
# from the original raster data.

