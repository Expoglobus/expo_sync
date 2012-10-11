module ExpoSync
  class CategoryAccountList < DataModel

    def self.store(data, delta = false)
      destroy_all if !delta
      data.each do |ca|
        category_account = find_or_create_by(:CategoryAccountID => ca[:CategoryAccountID])
        category_account.update_attributes(ca)
      end
    end
  end
end