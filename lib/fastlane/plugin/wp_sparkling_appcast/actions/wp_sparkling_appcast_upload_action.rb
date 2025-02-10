require 'fastlane/action'
require_relative '../helper/wp_sparkling_appcast_helper'

module Fastlane
  module Actions
    class WpSparklingAppcastUploadAction < Action

      def self.run(params)
        UI.message("Starting upload to WordPress Sparkling Appcast...")
        
        # Extract info from zip if parameters not provided
        if !params[:build_version] || !params[:build_number] || !params[:min_system_version]
          app_info = Helper::WpSparklingAppcastHelper.extract_app_info(params[:zip_file])
          
          if app_info
            params[:build_version] ||= app_info[:build_version]
            params[:build_number] ||= app_info[:build_number]
            params[:min_system_version] ||= app_info[:min_system_version]
            
            UI.success("Extracted from app bundle: v#{params[:build_version]} (#{params[:build_number]}) - min macOS #{params[:min_system_version]}")
          end
        end

        attachment_id = Helper::WpSparklingAppcastHelper.upload_zip(params)
        build_id = Helper::WpSparklingAppcastHelper.create_build_entry(params, attachment_id)
        
        return {
          attachment_id: attachment_id,
          build_id: build_id
        }
      end

      def self.description
        "This plugin helps you distribute your builds using WordPress's Sparkling Appcast plugin (Sparkle appcast.xml)"
      end

      def self.authors
        ["Usiel Riedl"]
      end

      def self.return_value
        "Returns a hash containing the attachment_id and build_id of the created resources"
      end

      def self.details
        "This plugin integrates with WordPress's Sparkling Appcast plugin to create Sparkle appcast.xml feeds for macOS app updates. " \
        "It handles uploading your app's zip file and creating the necessary build entries in WordPress. " \
        "Requirements:\n" \
        "- A WordPress installation with the Sparkling Appcast plugin\n" \
        "- WordPress Application Passwords for authentication\n" \
        "- A zip file containing your app update"
      end

      def self.example_code
        [
          'wp_sparkling_appcast_upload(
            base_url: "https://your-wordpress-site.com",
            wp_user: "your-username",
            wp_application_pw: ENV["WP_APP_PASSWORD"],
            changelog: "## Changes\n- Fixed some bugs\n- Added new features",
            zip_file: "path/to/YourApp.zip",
            track: 1
          )'
        ]
      end

      def self.category
        :beta
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :base_url,
            env_name: "WP_SPARKLING_APPCAST_BASE_URL",
            description: "Base URL of your WordPress installation",
            type: String,
            optional: false,
            verify_block: proc do |value|
              UI.user_error!("Invalid URL format for base_url") unless Helper::WpSparklingAppcastHelper.verify_url(value)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :wp_user,
            env_name: "WP_SPARKLING_APPCAST_USER",
            description: "WordPress username for authentication",
            type: String,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :wp_application_pw,
            env_name: "WP_SPARKLING_APPCAST_APPLICATION_PW",
            description: "WordPress application password for authentication",
            type: String,
            optional: false,
            sensitive: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :build_version,
            env_name: "WP_SPARKLING_APPCAST_BUILD_VERSION",
            description: "Version number of the build (e.g. 1.2.3). Will be extracted from app bundle if not provided",
            type: String,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :build_number,
            env_name: "WP_SPARKLING_APPCAST_BUILD_NUMBER",
            description: "Build number. Will be extracted from app bundle if not provided",
            type: Integer,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :min_system_version,
            env_name: "WP_SPARKLING_APPCAST_MIN_SYSTEM_VERSION",
            description: "Minimum system version required. Will be extracted from app bundle if not provided",
            type: String,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :changelog,
            env_name: "WP_SPARKLING_APPCAST_CHANGELOG",
            description: "Changelog for this version",
            type: String,
            optional: true,
            default_value: ""
          ),
          FastlaneCore::ConfigItem.new(
            key: :zip_file,
            env_name: "WP_SPARKLING_APPCAST_ZIP_FILE",
            description: "Path to the zip file to upload",
            type: String,
            optional: false,
            verify_block: proc do |value|
              UI.user_error!("Zip file not found at path '#{value}'") unless File.exist?(value)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :track,
            env_name: "WP_SPARKLING_APPCAST_TRACK",
            description: "Track ID for this build",
            type: Integer,
            optional: false
          )
        ]
      end

      def self.is_supported?(platform)
        platform == :mac
      end
    end
  end
end
