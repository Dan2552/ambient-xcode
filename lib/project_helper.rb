require 'xcodeproj'
require 'highline/import'

class ProjectHelper
  PROJECTS = Dir.glob('*.xcodeproj')

  def initialize
    @project = Xcodeproj::Project.open(PROJECTS.first)
  end

  def reset_project_to_defaults
    @project.build_configurations.each do |configuration|
      build_settings = configuration.build_settings
      build_settings.each { |k, _| build_settings.delete(k) }
    end
    save_changes
  end

  def reset_targets_to_defaults
    @project.targets.each do |target|
      @project.build_configurations.each do |configuration|
        build_settings = target.build_configuration_list.build_settings(configuration.to_s)
        build_settings.each { |k, _| build_settings.delete(k) }
      end
    end
  end

  def process_project_options(options)
    @project.build_configurations.each do |configuration|
      options.each do |key, value|
        configuration.build_settings[key] = value
        configuration.build_settings.delete(key) if value == nil
      end
    end
    save_changes
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
    save_changes
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
    save_changes
  end

  def print_info
    puts "Targets:"
    @project.targets.each { |t| puts "- #{t.to_s}" }
    puts ""
    puts "Build configurations:"
    @project.build_configurations.each { |c| puts "- #{c.to_s}" }
    puts ""
  end

  private

  def save_changes
    @project.save
  end
end
