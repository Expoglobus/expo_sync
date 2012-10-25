module ExpoSync
  class CategoryList < DataModel
    field :CategoryName, localize: true
    field :CategoryDescription, localize: true

    index "CategoryID" => 1

    def self.store_with_locale(data, delta = false)
      destroy_all if !delta
      grouped_data = data.group_by {|c| c[:CategoryID]}
      grouped_data.each do |id, category_locales|
        category = find_or_create_by(:CategoryID => id)
        category_locales.each do |a|
          I18n.with_locale a[:Name] do
            category.update_attributes(a.except(:Name, :ID))
          end
        end
      end
    end
  end
end