module ExpoSync
  class Project < DataModel
    field :ProjectName, localize: true
    field :ProjectDescription, localize: true
    field :PlaceDescription, localize: true

    def self.store_with_locale(data)
      project = find_or_create_by(:ProjectID => data[:ProjectID])
      project.update_attributes(data)

      data[:ProjectTranslations].each do |t|
        I18n.with_locale CULTURE_MAP[t[:CultureID]] do
          project.update_attributes({
            :ProjectName => t[:ProjectName],
            :ProjectDescription => t[:ProjectDescription],
            :PlaceDescription => t[:PlaceDescription]
            })
        end
      end
    end

    def self.current
      first
    end

    def self.find_by_code(code)
      unscoped.where(:ProjectCode => code).first
    end
  end
end