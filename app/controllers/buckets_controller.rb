require 'csv'
class BucketsController < ApplicationController
  def index
    @bucket = Bucket.find_by_slug(params[:slug])
    @bucket.present? ? render_index : render_index_bucket_not_found
  end

  def pages
    @bucket = Bucket.find_by_slug(params[:slug])
    @bucket.present? ? render_pages : render_pages_bucket_not_found
  end
  
  def list
    @buckets = Bucket.select('name, slug').all
    respond_to do |format|
      format.json { render json: @buckets }
      format.xml
    end
  end

  private

  def render_index
    @events = @bucket.query(params)
    respond_to do |format|
      format.json { render json: events_json }
      format.xml
      format.csv { events_csv }
      format.kml
    end
  end

  def render_index_bucket_not_found
    respond_to do |format|
      format.json { render json: { error: view_context.bucket_not_found_message }, status: :not_found }
    { error: view_context.bucket_not_found_message, status: :not_found }
      format.xml { render file: 'buckets/not_found', status: :not_found }
      format.csv { render inline: view_context.bucket_not_found_message, status: :not_found }
      format.kml { render file: 'buckets/not_found', status: :not_found }
    end
  end

  def render_pages
    @count = bucket_count(@bucket)
    respond_to do |format|
      format.json { render json: { pages: @count } }
      format.xml
    end
  end

  def render_pages_bucket_not_found
    respond_to do |format|
      format.json { render json: { error: view_context.bucket_not_found_message }, status: :not_found }
      format.xml { render file: 'buckets/not_found', status: :not_found }
    end
  end
  
  def events_json
    @events.collect{ |e| transform_attributes(e) }
  end

  def transform_attributes(event)
    extra = { lat: event.lat, lon: event.lon, date: event.date }
    event.attributes.slice('location', 'description').merge(extra)
  end

  def events_csv
    CSV.generate do |csv|
      csv << [ 'Date', 'Location', 'Description', 'Lat', 'Lon' ]
      @events.each do |e|
        csv << [e.date.strftime('%Y-%m-%d'), e.location, e.description, e.lat, e.lon]
      end
    end
  end

  def bucket_count(bucket)
    bucket.events.count / (params[:per_page].try(:to_i) || 20)
  end

end
