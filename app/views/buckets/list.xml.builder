xml.instruct!
xml.buckets do
  @buckets.each do |bucket|
    xml.bucket do
      xml.name bucket.name
      xml.slug bucket.slug
    end
  end
end
