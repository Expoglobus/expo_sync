module ExpoSync
  module Helpers
    module ClassBuilder
      def create_class(class_name, superclass, &block)
        klass = Class.new superclass, &block
        ExpoSync.const_set class_name, klass
      end
    end
  end
end