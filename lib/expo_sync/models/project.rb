module ExpoSync
  class Project < DataModel
    # field :CategoryName, localize: true
    # field :CategoryDescription, localize: true

    def self.store_with_locale(data)
      project = find_or_create_by(:ProjectID => data[:ProjectID])
      project.update_attributes(data)
    end

    def self.current
      first
    end
  end
end