module ExpoSync
  class CategoryList < DataModel
    field :CategoryName, localize: true
    field :CategoryDescription, localize: true

    def self.store_with_locale(data)
      destroy_all
      grouped_data = data.group_by {|c| c[:CategoryID]}
      grouped_data.each do |id, category_locales|
        category = find_or_create_by(:CategoryID => id)
        category_locales.each do |a|
          I18n.locale = a[:Name]
          category.update_attributes(a.except(:Name, :ID))
        end
      end
    end
  end
end