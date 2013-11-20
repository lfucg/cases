class BucketQuery

  SRID = 4326

  def initialize(bucket, params)
    @bucket = bucket
    @date = params[:date]
    @date_range = params[:date_range]
    @coords = params[:coords]
    @limit = params[:limit]
    @within = params[:within]
    @page = params[:page]
    @per_page = params[:per_page]
  end

  def validate
    return invalid! if @date && @date_range
    validate_date(@date) if @date
    validate_date_range(@date_range) if @date_range
    validate_coords(@coords) if @coords
    validate_limit(@limit) if @limit
    validate_within(@within) if @within
    validate_page(@page) if @page
    validate_per_page(@per_page) if @per_page
  end

  def valid?
    @valid ||= true
  end

  def run
    build_scope.all
  end

  private

  def invalid!
    @valid = false
  end

  def validate_date(date)
    return invalid! unless valid_date?(date)
  end

  def validate_date_range(date_range)
    return invalid! unless valid_date_range?(date_range)
    date_range.split(/-/).each { |d| validate_date(d) }
  end

  def validate_coords(coords)
    return invalid! unless valid_coordinates?(coords)
  end

  def validate_limit(limit)
    return invalid! unless valid_integer?(limit)
  end

  def validate_within(within)
    return invalid! unless valid_within?(within)
    distance = within.gsub(/mi|km/, '')
    return invalid! unless valid_integer?(distance)
  end

  def validate_page(page)
    return invalid! unless valid_integer?(page)
  end

  def validate_per_page(per_page)
    return invalid! unless valid_integer?(per_page)
  end

  def valid_date?(date)
    return false unless date.match(/\d{8}/)
    Date.valid_date?(date[0,4].to_i, date[4,2].to_i, date[6,2].to_i)
  end

  def valid_date_range?(date_range)
    date_range.match(/\d{8}-\d{8}/)
  end

  def valid_coordinates?(coords)
    coords.match(/^(\-?\d+(\.\d+)?),\s*(\-?\d+(\.\d+)?)$/)
  end

  def valid_within?(within)
    within.match(/mi|km/)
  end

  def valid_integer?(int)
    int.to_s.match(/^\d+$/)
  end

  def build_scope
    @conditions = []
    @args = []
    build_date_conditions if @date
    build_date_range_conditions if @date_range
    build_coords_conditions if @coords
    scope = @bucket.events.select('datetime, description, address, coords').scoped
    @conditions = @conditions.join(' AND ')
    scope = scope.where(@conditions, *@args).scoped

    @page = @page.try(:to_i)
    @per_page = @per_page.try(:to_i)
    @limit = @limit.try(:to_i)
    scope = scope.limit(@per_page || @limit).scoped
    if @page && @page > 1
      offset = (@per_page || 20) * (@page - 1)
      scope = scope.offset(offset).scoped
    elsif @limit
      scope = scope.limit(@limit).scoped
    end
    scope
  end

  def build_date_conditions
    @conditions << "datetime = ?"
    @args << parse_date(@date)
  end

  def build_date_range_conditions
    @conditions << "datetime BETWEEN ? AND ?"
    @date_range.split(/-/).each { |d| @args << parse_date(d) }
  end

  def build_coords_conditions
    distance = @within ? build_distance : 50
    lat, lon = @coords.split(/,/)
    @conditions << %(ST_DWithin(coords, ST_GeomFromText('POINT(#{lon.to_f} #{lat.to_f})', ?), ?))
    @args << SRID
    @args << distance
  end

  def build_distance
    return miles if miles?
    return kilometers if kilometers?
  end

  def miles?
    @within.match(/mi/)
  end

  def kilometers?
    @within.match(/km/)
  end

  def miles
    @within.gsub(/mi/, '').to_f * 1609.34
  end

  def kilometers
    @within.gsub(/km/, '').to_f * 1000
  end

  def parse_date(date)
    Date.strptime(date, '%Y%m%d').to_time
  end
end
