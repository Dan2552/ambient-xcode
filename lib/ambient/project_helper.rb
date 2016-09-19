module Ambient
  class ProjectHelper
    attr_reader :path

    def initialize(path)
      @path = path
      projects = Dir.glob(path + '/*.xcodeproj')
      @project = Xcodeproj::Project.open(projects.first)
    end

    def reset_project_to_defaults
      @project.build_configurations.each do |configuration|
        build_settings = configuration.build_settings
        build_settings.each { |k, _| build_settings.delete(k) }
      end
    end

    def reset_targets_to_defaults
      @project.targets.each do |target|
        @project.build_configurations.each do |configuration|
          build_settings = target.build_configuration_list.build_settings(configuration.to_s)
          build_settings.each { |k, _| build_settings.delete(k) }
        end
      end
    end

    def reset_capabilities_to_defaults
      @project.targets.each do |target|
        CapabilitiesHelper.new(@project, target).clear_capabilities
      end
    end

    def process_project_options(options)
      @project.build_configurations.each do |configuration|
        options.each do |key, value|
          configuration.build_settings[key] = value
          configuration.build_settings.delete(key) if value == nil
        end
      end
    end

    def process_shared_target_options(shared_target_options)
      @project.targets.each do |target|
        options = shared_target_options[target.to_s]
        if options
          @project.build_configurations.each do |configuration|
            target.build_configuration_list.build_settings(configuration.to_s).merge!(options)
          end
        end
      end
    end

    def process_target_options(target_options)
      @project.targets.each do |target|
        options = target_options[target.to_s]
        if options
          @project.build_configurations.each do |configuration|
            scheme_options = options[configuration.to_s]
            if scheme_options
              target.build_configuration_list.build_settings(configuration.to_s).merge!(scheme_options)
            end
          end
        end
      end
    end

    def process_capabilities(capabilities_hash)
      capabilities_hash.each do |target_name, capabilities|
        @project.targets.each do |target|
          if target_name == target.to_s
            helper = CapabilitiesHelper.new(@project, target)
            capabilities.each { |c| helper.enable_capability(c) }
          end
        end
      end
    end

    def process_scheme_options(options)
      @project.build_configurations.each do |configuration|
        scheme_options = options[configuration.to_s] || {}
        scheme_options.each do |key, value|
          configuration.build_settings[key] = value
          configuration.build_settings.delete(key) if value == nil
        end
      end
    end

    def process_development_teams(development_teams)
      development_teams.each do |target_name, development_team|
        @project.targets.each do |target|
          if target_name == target.to_s
            helper = CapabilitiesHelper.new(@project, target)
            helper.set_development_team(development_team)
          end
        end
      end
    end

    def print_info
      puts ""
      puts "Targets:"
      @project.targets.each { |t| puts "- #{t.to_s}" }
      puts ""
      puts "Build configurations:"
      @project.build_configurations.each { |c| puts "- #{c.to_s}" }
      puts ""
    end

    def save_changes
      @project.save
    end
  end
end
