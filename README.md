Ambient environment for Xcode projects
======================================

Ambient lets you define all of your Xcode project environment settings all in one easy to read Ruby file, and re-apply it to your Xcode project to ensure settings are correct.

An `xcconfig` file can be used in order to help abstract your settings away from the main project file. The disadvantage of `xcconfig` files though is that they can still be overridden by settings defined in the project. Ambient doesn't have this issue as it simply overwrites the values in the project file.


Installation
============

Simply run:
```bash
gem install ambient-xcode
```

Or if you use Bundler, add the following to your `Gemfile`:
```ruby
gem "ambient-xcode"
```

Usage
=====

Create an `Ambientfile` defining your project in the same directory as your `*.xcodeproj` file.

Here's a sample of the `Ambientfile` structure:
```ruby
base_ios_settings! "MyProject"

target "MyProject" do
  capability :healthkit
  capability :apple_pay

  scheme "Debug" do
    option "PRODUCT_NAME", "Debug"
    option "BUNDLE_DISPLAY_NAME_SUFFIX", "uk.danielgreen.MyProject"
  end
end

plist("MyProject/Info.plist") do
  entry "LSApplicationQueriesSchemes", [ "dbapi-2", "dbapi-8-emm"]
end
```

Run `ambient` from the command line to write your settings into your project:
```
usage:
$ ambient COMMAND

Commands:
+ [no arguments]	Applies the settings from the Ambientfile
+ init			Creates an Ambientfile in the current directory
+ new NAME		Creates a new iOS Xcode project with given name
+ [anything else]	Applies the settings from the file name supplied
```

You can also have more than one `Ambientfile` for the same project. Just name it something else and run `ambient [filename]` (e.g. `ambient Ambientfile-enterprise`). Use `use_settings_from` to inherit settings:

```ruby
use_settings_from 'Ambientfile'

target "Monies" do
  development_team "341MONEY25"
  capability :apple_pay
end
```


Notes
=====

- The [example Ambientfile](https://github.com/Dan2552/ambient-xcode/blob/master/example/Ambientfile) or [example Ambientfile-objc](https://github.com/Dan2552/ambient-xcode/blob/master/example/Ambientfile-objc) matches the exact settings of a new iOS project.
- Use the `use_defaults_for_everything_not_specified_in_this_file!` setting to ensure your project file is clean. Warning though: this setting will clear all your targets' settings, so be sure to define absolutely every setting in the `Ambientfile` if you want to use this.
- When defining settings directly within a target, the setting is set to each scheme.
- The name of the constants used for `option` is located in the **Quick Help** section in Xcode
![Constants](example/images/Constant.png)

Possible future features
========================

- Automatic editing of `.entitlements`
- Helper method to change build phases to default
- Version number + build number
- Provisioning profiles from searching by name rather than storing a uuid (so it actually works across teams)
- Ability to not have to commit `*.xcodeproj` into version control (maybe too far?)
