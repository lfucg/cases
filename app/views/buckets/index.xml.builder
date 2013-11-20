xml.instruct!
xml.events do
  @events.each do |event|
    xml.event do
      xml.date event.datetime.strftime('%Y-%m-%d')
      xml.address event.address
      xml.description event.description
      xml.lat event.lat
      xml.lon event.lon
    end
  end
end
