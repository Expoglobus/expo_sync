module ExpoSync
  class AccountList < DataModel
    # include CachedModel
    field :ExponentName, localize: true
    field :ExponentDescription, localize: true
    field :OrganizationName, localize: true

    index "AccountID" => 1

    index "Plan" => 1
    index "PlanBlockIDs" => 1

    def self.store_with_locale(data, delta = false)
      delete_all if !delta
      grouped_data = data.group_by {|a| a[:AccountID]}
      grouped_data.each do |id, account_locales|
        account = find_or_create_by(:AccountID => id)
        account_locales.each do |a|
          I18n.with_locale a[:Name] do
            account.update_attributes(a.except(:Name, :ID))
          end
        end
      end
    end
  end
end