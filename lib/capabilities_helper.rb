require 'xcodeproj'
class CapabilitiesHelper
  CAPABILITIES = {
    application_group_ios: "ApplicationGroups.iOS",
    background_modes: "BackgroundModes",
    data_protection: "DataProtection",
    game_center: "GameCenter",
    healthkit: "HealthKit",
    health_kit: "HealthKit",
    homekit: "HomeKit",
    home_kit: "HomeKit",
    in_app_purchase: "InAppPurchase",
    inter_app_audio: "InterAppAudio",
    keychain: "Keychain",
    maps: "Maps.iOS",
    apple_pay: "OMC",
    passbook: "Passbook",
    wallet: "Passbook",
    safari_keychain: "SafariKeychain",
    personal_vpn: "VPNLite",
    wireless_accessory_configuration: "WAC",
    icloud: "iCloud"
  }

  def initialize(project, target)
    @project = project
    @target = target
  end

  def clear_capabilities
    capabilities.delete_if { |_, _| true } if capabilities
  end

  def enable_capability(capability)
    capabilities[capability_key(capability)] = {"enabled"=>"1"}
  end

  def disable_capability(capability)
    capabilities.delete(capability_key(capability))
  end

  private

  def capabilities
    target_attributes["SystemCapabilities"]
  end

  def target_attributes
    @project.root_object.attributes["TargetAttributes"][@target.uuid]
  end

  def capability_key(capability)
    capability = CAPABILITIES[capability] || capability.to_s
    prefix = "com.apple."
    capability = "#{prefix}#{capability}" unless capability.start_with? prefix
    capability
  end

end
