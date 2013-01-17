module ExpoSync
  class CategoryAccountList < DataModel

    index "CategoryAccountID" => 1

    index({ :AccountID => 1, :CategoryID => 1 }, { unique: true })

    def self.store(data, delta = false)
      delete_all if !delta
      data.each do |ca|
        category_account = find_or_create_by(:CategoryAccountID => ca[:CategoryAccountID])
        category_account.update_attributes(ca)
      end
    end
  end
end