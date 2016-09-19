module Ambient
  module DSL
    class TargetScope
      attr_reader :application,
                  :name

      def initialize(application, name)
        @application = application
        @name = name
      end

      def configure(&block)
        instance_eval(&block)
      end

      def option(option_name, value)
        target_name = @name
        application.configure { set_option(option_name, value, target: target_name) }
      end

      def scheme(name, parent: nil, &block)
        SchemeScope.new(application, self, name, parent).configure(&block)
      end

      def capability(capability_name)
        target_name = @name
        application.configure { set_capability(target_name, capability_name) }
      end

      def development_team(team_name)
        target_name = @name
        application.configure { set_development_team(target_name, team_name) }
      end
    end
  end
end
