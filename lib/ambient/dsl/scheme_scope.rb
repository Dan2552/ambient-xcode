module Ambient
  module DSL
    class SchemeScope
      attr_reader :application

      def initialize(application, target, name, parent)
        @application = application
        @target = target
        @name = name
        @parent = parent

        application.configure do
          set_parent_scheme(
            target: target && target.name,
            child: name,
            parent: parent
          )
        end
      end

      def configure(&block)
        if block
          instance_eval(&block)
        end
      end

      def option(option_name, value)
        target = @target
        name = @name
        parent = @parent

        if target
          application.configure { set_option(option_name, value, target: target.name, scheme: name, parent: parent) }
        else
          application.configure { set_option(option_name, value, scheme: name, parent: parent) }
        end
      end
    end
  end
end
