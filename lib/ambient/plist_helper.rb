module Ambient
  class PlistHelper
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def add_entry(key, value)
      plist_as_dictionary[key] = value
      puts "applying to plist: #{path} #{key}"
      save
    end

    private

    def plist_as_dictionary
      @plist_as_dictionary ||= Plist::parse_xml(path)
    end

    def to_plist
      plist_as_dictionary.to_plist
    end

    def save
      File.open(path, 'w') { |file| file.write(to_plist) }
    end
  end
end
