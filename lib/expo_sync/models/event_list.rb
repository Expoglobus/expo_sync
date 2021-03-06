module ExpoSync
  class EventList < DataModel
    field :EventDescription, localize: true
    field :EventName, localize: true

    field :EventDate,     type: DateTime
    field :StartTime,     type: DateTime
    field :EndTime,       type: DateTime
    field :AvailableFrom, type: DateTime
    field :AvailableTo,   type: DateTime

    index "EventID" => 1

    def self.store_with_locale(data, delta = false)
      delete_all if !delta
      data.each do |e|
        event = find_or_create_by(:EventID => e[:EventID])
        event.update_attributes(e)

        e[:EventTranslations].each do |t|
          I18n.with_locale CULTURE_MAP[t[:CultureID]] do
            event.update_attributes({:EventDescription => t[:EventDescription], :EventName => t[:EventName]})
          end
        end
      end
    end
  end
end