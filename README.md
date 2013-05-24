geoevents
=========

Geoevents is an API for handling geocentric government service events like 311 calls, building inspection complaints and permits, code inspection and enforcement cases and more.

## Usage

Data is available in XML, JSON and CSV formats.

Query API:

    /:bucket.json?date_range=01012013-05242013
    /:bucket.json?date=01012013
    /:bucket.json?coords=38.044624,-84.495629

Bulk download API:
    /:bucket/all.json
    
Available Buckets:

    /LEX # LexCall 311 calls
    /BIC # Building inspection complaints
    /BIP # Building inspection permits
    /CEC # Code enforcement cases
    /HPC # Historic preservation cases
    /PTR # Planning cases
    /ROW # Right of way permits
