module ExpoSync
  class BlockList < DataModel
    field :BlockDescription, localize: true
    field :BlockName, localize: true

    def self.store_with_locale(data, delta = false)
      destroy_all if !delta
      data.each do |b|
        block = find_or_create_by(:BlockID => b[:BlockID])
        block.update_attributes(b)

        b[:BlockTranslations].each do |t|
          I18n.with_locale CULTURE_MAP[t[:CultureID]] do
            block.update_attributes({:BlockDescription => t[:BlockDescription], :BlockName => t[:BlockName]})
          end
        end
      end
    end
  end
end