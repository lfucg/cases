class Event < ActiveRecord::Base
  belongs_to :bucket

  set_rgeo_factory_for_column(:coords,
      RGeo::Geographic.spherical_factory(srid: 4326))

  validates :date, presence: true
  validates :description, presence: true
  validates :location, presence: true

  scope :geocodeable, where(geocoded: false)

  def lat
    coords.try(:lat)
  end

  def lon
    coords.try(:lon)
  end
end
