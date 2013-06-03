geoevents
=========

Geoevents is an API for handling geospatial government service events like 311 calls, building inspection complaints and permits, code inspection and enforcement cases and more.

## Usage

Event data is available in XML, JSON, KML and CSV formats.

Query API:

    /:bucket.json?date_range=20130101-20130524
    /:bucket.json?date=20130101
    /:bucket.json?date=20130101&limit=20

Pagination:

    /:bucket/pages.json&per_page=10 # get number of pages (JSON and XML Only)
    /:bucket.json?page=2&per_page=10

Geospatial API:

    /:bucket.json?coords=38.044624,-84.495629&within=10mi
    /:bucket.json?coords=38.044624,-84.495629&within=5km

Bulk download API (download everything):

    /:bucket.json
    
Available Buckets (JSON and XML only):

    /buckets.json

Current Buckets:

    /lex # LexCall 311 calls
    /bic # Building inspection complaints
    /bip # Building inspection permits
    /cec # Code enforcement cases
    /hpc # Historic preservation cases
    /ptr # Planning cases
    /row # Right of way permits
