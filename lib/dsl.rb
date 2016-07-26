def use_settings_from(filename)
  Ambient.configure { run_ambientfile(filename) }
end

def option(name, value)
  Ambient.configure { set_option(name, value) }
end

def base_ios_settings!(project_name, prefix: "", tests: false, ui_tests: false, swift: true, target: nil, test_target: nil, ui_test_target: nil)
  use_defaults_for_everything_not_specified_in_this_file!
  enable_default_warnings!

  target ||= "project_name"
  test_target ||= "#{project_name}Tests"
  ui_test_target ||= "#{project_name}UITests"
  tests = true if test_target
  ui_tests = true if ui_test_target

  option "ALWAYS_SEARCH_USER_PATHS", false
  option "CLANG_CXX_LANGUAGE_STANDARD", "gnu++0x"
  option "CLANG_CXX_LIBRARY", "libc++"
  option "CLANG_ENABLE_MODULES", true
  option "CLANG_ENABLE_OBJC_ARC", true

  option "CODE_SIGN_IDENTITY[sdk=iphoneos*]", "iPhone Developer"
  option "COPY_PHASE_STRIP", false

  option "ENABLE_STRICT_OBJC_MSGSEND", true
  option "GCC_C_LANGUAGE_STANDARD", "gnu99"
  option "GCC_NO_COMMON_BLOCKS", true
  option "SDKROOT", "iphoneos"
  option "IPHONEOS_DEPLOYMENT_TARGET", "9.0"

  scheme "Debug" do
    option "DEBUG_INFORMATION_FORMAT", "dwarf"
    option "ENABLE_TESTABILITY", true
    option "MTL_ENABLE_DEBUG_INFO", true
    option "ONLY_ACTIVE_ARCH", true
    option "GCC_DYNAMIC_NO_PIC", false
    option "GCC_OPTIMIZATION_LEVEL", "0"
    option "GCC_PREPROCESSOR_DEFINITIONS", ["DEBUG=1", "$(inherited)"]
    option "SWIFT_OPTIMIZATION_LEVEL", "-Onone" if swift
  end

  scheme "Release" do
    option "DEBUG_INFORMATION_FORMAT", "dwarf-with-dsym"
    option "ENABLE_NS_ASSERTIONS", false
    option "MTL_ENABLE_DEBUG_INFO", false
    option "VALIDATE_PRODUCT", true
  end

  target project_name do
    option "INFOPLIST_FILE", "#{project_name}/Info.plist"
    option "PRODUCT_BUNDLE_IDENTIFIER", "#{prefix}#{project_name}"
    option "ASSETCATALOG_COMPILER_APPICON_NAME", "AppIcon"
    option "LD_RUNPATH_SEARCH_PATHS", "$(inherited) @executable_path/Frameworks"
    option "PRODUCT_NAME", "$(TARGET_NAME)"
  end

  if tests
    target test_target do
      option "INFOPLIST_FILE", "#{project_name}Tests/Info.plist"
      option "BUNDLE_LOADER", "$(TEST_HOST)"
      option "TEST_HOST", "$(BUILT_PRODUCTS_DIR)/#{project_name}.app/#{project_name}"
      option "PRODUCT_BUNDLE_IDENTIFIER", "#{prefix}#{project_name}Tests"
      option "LD_RUNPATH_SEARCH_PATHS", "$(inherited) @executable_path/Frameworks @loader_path/Frameworks"
      option "PRODUCT_NAME", "$(TARGET_NAME)"
    end
  end

  if ui_tests
    target ui_test_target do
      option "INFOPLIST_FILE", "#{project_name}UITests/Info.plist"
      option "TEST_TARGET_NAME", "#{project_name}"
      option "PRODUCT_BUNDLE_IDENTIFIER", "#{prefix}#{project_name}UITests"
      option "LD_RUNPATH_SEARCH_PATHS", "$(inherited) @executable_path/Frameworks @loader_path/Frameworks"
      option "USES_XCTRUNNER", "YES"
      option "PRODUCT_NAME", "$(TARGET_NAME)"
    end
  end
end

def enable_extra_warnings_and_static_analyser!
  warnings = %w(GCC_WARN_INITIALIZER_NOT_FULLY_BRACKETED
    GCC_WARN_MISSING_PARENTHESES
    GCC_WARN_ABOUT_RETURN_TYPE
    GCC_WARN_SIGN_COMPARE
    GCC_WARN_CHECK_SWITCH_STATEMENTS
    GCC_WARN_UNUSED_FUNCTION
    GCC_WARN_UNUSED_LABEL
    GCC_WARN_UNUSED_VALUE
    GCC_WARN_UNUSED_VARIABLE
    GCC_WARN_SHADOW
    GCC_WARN_64_TO_32_BIT_CONVERSION
    GCC_WARN_ABOUT_MISSING_FIELD_INITIALIZERS
    GCC_WARN_UNDECLARED_SELECTOR
    GCC_WARN_TYPECHECK_CALLS_TO_PRINTF
    GCC_WARN_UNINITIALIZED_AUTOS
    CLANG_WARN_INT_CONVERSION
    CLANG_WARN_ENUM_CONVERSION
    CLANG_WARN_CONSTANT_CONVERSION
    CLANG_WARN_BOOL_CONVERSION
    CLANG_WARN_EMPTY_BODY
    CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION
    CLANG_WARN__DUPLICATE_METHOD_MATCH
    GCC_WARN_64_TO_32_BIT_CONVERSION
    RUN_CLANG_STATIC_ANALYZER
    GCC_TREAT_WARNINGS_AS_ERRORS)
  warnings.each { |w| option(w, true) }
end

def enable_default_warnings!
  truthy = %w(CLANG_WARN_BOOL_CONVERSION
    CLANG_WARN_CONSTANT_CONVERSION
    CLANG_WARN_EMPTY_BODY
    CLANG_WARN_ENUM_CONVERSION
    CLANG_WARN_INT_CONVERSION
    CLANG_WARN_UNREACHABLE_CODE
    CLANG_WARN__DUPLICATE_METHOD_MATCH
    GCC_WARN_64_TO_32_BIT_CONVERSION
    GCC_WARN_UNDECLARED_SELECTOR
    GCC_WARN_UNUSED_FUNCTION
    GCC_WARN_UNUSED_VARIABLE)
  error = %w(CLANG_WARN_DIRECT_OBJC_ISA_USAGE
    CLANG_WARN_OBJC_ROOT_CLASS
    GCC_WARN_ABOUT_RETURN_TYPE)
  aggressive = %w(GCC_WARN_UNINITIALIZED_AUTOS)

  truthy.each { |w| option(w, true) }
  error.each { |w| option(w, "YES_ERROR") }
  aggressive.each { |w| option(w, "YES_AGGRESSIVE") }
end

def target(name, &block)
  TargetScope.new(name).configure(&block)
end

def use_defaults_for_everything_not_specified_in_this_file!
  Ambient.configure { @use_defaults = true }
end

def scheme(name, parent: nil, &block)
  SchemeScope.new(nil, name, parent).configure(&block)
end

def plist(path, &block)
  PlistScope.new(path).configure(&block)
end

class PlistScope
  attr_reader :helper

  def initialize(path)
    @helper = PlistHelper.new(path)
  end

  def configure(&block)
    instance_eval(&block)
  end

  def entry(key, value)
    helper.add_entry(key, value)
  end
end

class TargetScope
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def configure(&block)
    instance_eval(&block)
  end

  def option(option_name, value)
    target_name = @name
    Ambient.configure { set_option(option_name, value, target: target_name) }
  end

  def scheme(name, parent: nil, &block)
    SchemeScope.new(self, name, parent).configure(&block)
  end

  def capability(capability_name)
    target_name = @name
    Ambient.configure { set_capability(target_name, capability_name) }
  end

  def development_team(team_name)
    target_name = @name
    Ambient.configure { set_development_team(target_name, team_name) }
  end
end

class SchemeScope
  def initialize(target, name, parent)
    @target = target
    @name = name
    @parent = parent

    Ambient.configure do
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
      Ambient.configure { set_option(option_name, value, target: target.name, scheme: name, parent: parent) }
    else
      Ambient.configure { set_option(option_name, value, scheme: name, parent: parent) }
    end
  end
end
