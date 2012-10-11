module ExpoSync
  class RemoteData < Hash

    def date_fields
      @date_fields || []
    end

    def normalize!(fields = [])
      @date_fields = fields
      normalize_date!
      each do |_k, v|
        v.normalize!(date_fields) if v.kind_of?(RemoteData)
        v.map { |h| h.normalize!(date_fields) } if v.kind_of?(Array)
      end
    end

    def normalize_date!
      date_fields.each do |key|
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