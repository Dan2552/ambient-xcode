module Ambient
  class Application
    attr_reader :path

    def initialize(path = nil)
      @path = path || Dir.pwd

      @use_defaults = false
      @project_options = {}
      @shared_target_options = {}
      @target_options = {}
      @scheme_options = {}
      @parents = {}
      @capabilities = {}
      @development_teams = {}
    end

    def run_ambientfile(file = nil)
      setup_project(file || "Ambientfile")
    end

    def configure(&block)
      instance_eval(&block)
    end

    private

    def project_helper
      @project_helper ||= ProjectHelper.new(path)
    end

    def set_parent_scheme(target: nil, child: nil, parent: nil)
      target = target || :all
      @parents[target] ||= {}
      @parents[target][child] = parent
    end

    def set_option(option, value, target: nil, scheme: nil, parent: nil)
      value = "YES" if value == true
      value = "NO" if value == false
      value = nil if value == :default

      if target
        if scheme
          @target_options[target] ||= {}
          @target_options[target][scheme] ||= {}
          @target_options[target][scheme][option] = value
        else
          @shared_target_options[target] ||= {}
          @shared_target_options[target][option] = value
        end
      else
        if scheme
          @scheme_options[scheme] ||= {}
          @scheme_options[scheme][option] = value
        else
          @project_options[option] = value
        end
      end
    end

    def set_capability(target_name, capability_name)
      capabilities = @capabilities[target_name] ||= []
      capabilities << capability_name
    end

    def set_development_team(target_name, team_name)
      @development_teams[target_name] = team_name
    end

    def setup_project(ambientfile)
      read(ambientfile)
      project_helper.print_info
      reset_project_to_defaults if @use_defaults
      reset_targets_to_defaults if @use_defaults
      reset_capabilites_to_defaults if @use_defaults
      load_in_parent_scheme_values
      process_project_options
      process_scheme_options
      process_shared_target_options
      process_target_options
      process_capabilities
      process_development_teams
      project_helper.save_changes
    end

    def reset_project_to_defaults
      puts "resetting project settings to xcode default settings"
      project_helper.reset_project_to_defaults
    end

    def reset_targets_to_defaults
      puts "resetting target settings to xcode default settings"
      project_helper.reset_targets_to_defaults
    end

    def reset_capabilites_to_defaults
      puts "resetting capabilities to xcode default settings"
      project_helper.reset_capabilities_to_defaults
    end

    def process_project_options
      puts "applying ambient project settings"
      project_helper.process_project_options(@project_options)
    end

    def process_scheme_options
      puts "applying ambient scheme settings"
      project_helper.process_scheme_options(@scheme_options)
    end

    def process_shared_target_options
      puts "applying ambient shared target settings"
      project_helper.process_shared_target_options(@shared_target_options)
    end

    def process_target_options
      puts "applying ambient target settings"
      project_helper.process_target_options(@target_options)
    end

    def process_capabilities
      puts "applying ambient capabilities"
      project_helper.process_capabilities(@capabilities)
    end

    def process_development_teams
      puts "applying ambient development teams"
      project_helper.process_development_teams(@development_teams)
    end

    def load_in_parent_scheme_values
      @parents.each do |target, parents|
        parents.each do |child, parent|
          if parent
            if target == :all
              puts "Identified #{child} as a child of #{parent}"
              child_options = @scheme_options[child]
              parent_options = @scheme_options[parent]
            else
              target_options = @target_options[target]
              child_options = target_options[child]
              parent_options = target_options[parent]
            end
            child_options.merge!(parent_options) { |_, child, _| child }
          end
        end
      end
    end

    def read(filename)
      puts "# Reading settings from #{filename}"
      ambient = File.join(path, filename)

      unless File.exists?(ambient)
        puts "😱  #{filename} not found in current directory."
        exit 1
      end

      DSL::MainScope.new(self).instance_eval do
        eval(File.read(ambient))
      end
    end
  end
end
