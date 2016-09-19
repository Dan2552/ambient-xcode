module Ambient
  class Init
    attr_reader :path,
                :project_name,
                :project_prefix

    def initialize(path = nil, project_name = nil, project_prefix = nil)
      @path = path || Dir.pwd
      @project_name = project_name || "MyProject"
      @project_prefix = project_prefix || "com.#{@project_name.downcase}."
    end

    def create_ambientfile
      puts "# Creating Ambientfile..."
      write_file
      puts "File created at #{filepath}"
    end

    private

    def write_file
      File.open(filepath, 'w') { |file| file.write(contents) }
    end

    def filepath
      "#{path}/Ambientfile"
    end

    def contents
      "base_ios_settings! \"#{project_name}\", prefix: \"#{project_prefix}\"\n"
    end
  end
end
