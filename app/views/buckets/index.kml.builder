xml.instruct!
xml.kml xmlns: 'http://www.opengis.net/kml/2.2' do
  @events.each do |event|
    xml.Placemark do
      xml.name "#{event.date.strftime('%Y-%m-%d')} #{event.location}"
      xml.description event.description
      xml.Point do
        xml.coordinates "#{event.lon},#{event.lat},0"
      end
    end
  end
end
