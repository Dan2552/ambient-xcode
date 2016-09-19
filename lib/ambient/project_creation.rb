module Ambient
  class ProjectCreation
    attr_reader :path,
                :name

    def initialize(path, name)
      @path = path
      @name = name
      check_name!
    end

    def create_ios_project
      check_already_exists!
      puts "# Setting up project..."
      copy_from_template
      rename_project_to_name
      create_ambientfile
      run_ambientfile
    end

    private

    def check_already_exists!
      return unless File.exists?(project_path)

      puts "😱  #{name} already exists in the current directory"
      exit 1
    end

    def check_name!
      return if name

      puts "😱  You must specify a project name when creating a new project"
      puts "e.g. `ambient new MyProject`"
      exit(1)
    end

    def run_ambientfile
      Application.new(project_path).run_ambientfile
    end

    def create_ambientfile
      Init.new(project_path, name).create_ambientfile
    end

    def copy_from_template
      FileUtils.copy_entry ios_template_path, project_path
    end

    def rename_project_to_name
      FileUtils.mv "#{project_path}/PRODUCTNAME",
                   "#{project_path}/#{name}"
      FileUtils.mv "#{project_path}/PRODUCTNAME.xcodeproj",
                   "#{project_path}/#{name}.xcodeproj"
    end

    def project_path
      path + "/#{name}"
    end

    def ios_template_path
      File.expand_path("../../../templates/ios", __FILE__)
    end
  end
end
