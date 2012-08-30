module ExpoSync
  module Helpers
    module PathBuilder

      # Router maper.
      #  path_map "http://google.com/:method/:name", :method => "search", :name => "freezbee"
      #  => "http://google.com/search/freezbee"

      def path_map(path, args)
        # Normalize Hash
        if args.kind_of? Hash
          h = {}
          args.each do |k, v|
            case k
            when Symbol
              h[k.inspect] = v
            else
              k = k.to_s
              h[k =~ /\A:/ ? k : ":#{k}"] = v
            end
          end
          path.gsub(/#{h.keys.join "|"}/, h)
        end
      end
    end
  end
end