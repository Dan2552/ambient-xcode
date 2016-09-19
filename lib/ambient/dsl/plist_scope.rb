module Ambient
  module DSL
    class PlistScope
      attr_reader :application,
                  :helper

      def initialize(application, path)
        @application = application
        @helper = PlistHelper.new(path)
      end

      def configure(&block)
        instance_eval(&block)
      end

      def entry(key, value)
        helper.add_entry(key, value)
      end
    end
  end
end
