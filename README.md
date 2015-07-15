Ambient environment for Xcode projects
======================================

Ambient lets you define all of your xcode project environment settings all in one easy to read Ruby file, and re-apply it to your Xcode project to ensure settings are correct.

An `xcconfig` file can be used in order to help abstract your settings away from the main project file. The disadvantage of `xcconfig` files though is that they can still be overridden by settings defined in the project. Ambient doesn't have this issue as it simply overwrites the values in the project file.

Installation
============

Simply run:
```
gem install ambient-xcode
```

Or if you use Bundler, add the following to your `Gemfile`:
```
gem "ambient-xcode"
```

Usage
=====

Create an `Ambientfile` defining your project in the same directory as your `*.xcodeproj` file.

Here's a sample of the `Ambientfile` structure:
```ruby
enable_default_warnings!
use_defaults_for_everything_not_specified_in_this_file!

option "IPHONEOS_DEPLOYMENT_TARGET", "7.0"
option "SDKROOT", "iphoneos"
option "CLANG_ENABLE_OBJC_ARC", true
option "CLANG_ENABLE_MODULES", true

target "MyProject" do
  capability :healthkit
  capability :apple_pay

  scheme "Debug" do
    option "PRODUCT_NAME", "Debug"
    option "BUNDLE_DISPLAY_NAME_SUFFIX", "uk.danielgreen.MyProject"
  end
end
```

Run `ambient` from the command line to write your settings into your project.

The [example Ambientfile](https://github.com/Dan2552/ambient-xcode/blob/master/example/Ambientfile) matches the exact settings of a new iOS project.

If for any reason you want multiple Ambientfile, you can:
```
use_settings_from 'Ambientfile'

target "Babylon" do
  capability :apple_pay
end
```

Just run `ambient [filename]` (i.e. `ambient Ambientfile-enterprise`)

Notes
=====

- You can re-run `ambient` as many times as possible.
- Use the `use_defaults_for_everything_not_specified_in_this_file!` setting to ensure your project file is clean. Warning though: this setting will clear all your targets' settings, so be sure to define absolutely every setting in the `Ambientfile` if you want to use this.
- When defining settings directly within a target, the setting is set to each scheme.


Possible future features
========================

- Defining capabilities (per target if possible... using `.entitlements` maybe)
- Helper method to change build phases to default
- Version number + build number
- Team ID
- Provisioning profiles from searching by name rather than storing a uuid (so it actually works across teams)
- `Info.plist` definitions
- ?
- Ability to not have to commit `*.xcodeproj` into version control (maybe too far?)
