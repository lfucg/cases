class Bucket < ActiveRecord::Base
  has_many :events

  validates :slug, :uniqueness => true

  before_validation :set_slug

  def query(params)
    q = Query.new(self, params)
    q.validate
    q.valid? ? q.run : []
  end

  def set_slug
    self.slug = name.downcase.gsub(/[^\w]+/, '')
  end
end
