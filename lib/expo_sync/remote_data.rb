module ExpoSync
  class RemoteData < Hash
    cattr_accessor :date_keys

    self.date_keys = []

    def normalize!
      normalize_date!
      each do |_k, v|
        v.normalize! if v.kind_of?(RemoteData)
        v.map { |h| h.normalize! } if v.kind_of?(Array)
      end
    end

    def normalize_date!
      date_keys.each do |key|
        include?(key) ? self[key] = parse_date(self[key]) : next
      end
    end

    private
    def parse_date(str)
      if str =~ /\/Date\((\d+)\+(\d+)\)\// # Parse fuckin Jora "/Date(1345033161020+0300)/"
        Time.at($1.to_f / 1_000.0)
      end
    end
  end
end