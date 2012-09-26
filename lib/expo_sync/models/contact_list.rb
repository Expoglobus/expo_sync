module ExpoSync
  class ContactList < DataModel
    field :Title, localize: true
    field :FirstName, localize: true
    field :LastName, localize: true
    field :MiddleName, localize: true
    field :Position, localize: true
    field :ContactDescription, localize: true

    def self.store_with_locale(data)
      destroy_all
      grouped_data = data.group_by {|a| a[:ContactID]}
      grouped_data.each do |id, contact_locales|
        contact = find_or_create_by(:ContactID => id)
        contact_locales.each do |a|
          I18n.locale = a[:Name]
          contact.update_attributes(a.except(:Name, :ID))
        end
      end
    end
  end
end