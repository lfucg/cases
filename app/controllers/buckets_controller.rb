require 'csv'
class BucketsController < ApplicationController
  def index
    bucket = Bucket.find_by_slug(params[:slug])
    @events = bucket.query(params)
    respond_to do |format|
      format.json { render json: events_json }
      format.xml
      format.csv { render text: events_csv }
      format.kml
    end
  end

  def pages
    @bucket = Bucket.find_by_slug(params[:slug])
    @count = @bucket.events.count / (params[:per_page].try(:to_i) || 20)
    respond_to do |format|
      format.json { render json: { pages: @count } }
      format.xml
    end
  end
  
  def list
    @buckets = Bucket.select('name, slug').all
    respond_to do |format|
      format.json { render json: @buckets }
      format.xml
    end
  end

  private

  def events_json
    @events.collect{ |e| transform_attributes(e) }
  end
  
  def transform_attributes(event)
    latlon = { lat: event.lat, lon: event.lon }
    event.attributes.slice('date', 'location', 'description').merge(latlon)
  end

  def events_csv
    CSV.generate do |csv|
      csv << [ 'Date', 'Location', 'Description', 'Lat', 'Lon' ]
      @events.each do |e|
        csv << [e.date.strftime('%Y-%m-%d'), e.location, e.description, e.lat, e.lon]
      end
    end
  end

end
