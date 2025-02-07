require 'fastlane_core/ui/ui'
require 'net/http'
require 'uri'
require 'json'
require 'zip'
require 'plist'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class WpSparklingAppcastHelper
      # class methods that you define here become available in your action
      # as `Helper::WpSparklingAppcastHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the wp_sparkling_appcast plugin helper!")
      end

      def self.upload_zip(params)
        zip_uri = URI.parse("#{params[:base_url]}/wp-json/wp/v2/media")
        zip_uri.query = URI.encode_www_form({
          'status' => 'publish',
          'title' => "#{File.basename(params[:zip_file], '.*')} #{params[:build_version]} (#{params[:build_number]})"
        })

        UI.message("Uploading zip file...")
        
        zip_request = Net::HTTP::Post.new(zip_uri)
        zip_request.basic_auth(params[:wp_user], params[:wp_application_pw])
        zip_request['Content-Type'] = 'application/zip'
        zip_request['Content-Disposition'] = "attachment; filename=\"#{File.basename(params[:zip_file])}\""
        
        zip_data = File.read(params[:zip_file])
        zip_request.body = zip_data

        response = make_request(zip_uri, zip_request, read_timeout: 300)
        attachment_data = JSON.parse(response.body)
        
        UI.success("Successfully uploaded zip file with ID: #{attachment_data['id']}")
        attachment_data['id']
      end

      def self.create_build_entry(params, attachment_id)
        build_uri = URI.parse("#{params[:base_url]}/wp-json/wp/v2/sappcast_app_build")
        
        UI.message("Creating app build entry...")

        build_request = Net::HTTP::Post.new(build_uri)
        build_request.basic_auth(params[:wp_user], params[:wp_application_pw])
        build_request['Content-Type'] = 'application/json'
        
        build_data = {
          meta: {
            sappcast_app_build_version: params[:build_version],
            sappcast_app_build_number: params[:build_number],
            sappcast_app_build_min_system_version: params[:min_system_version],
            sappcast_app_build_attachment_id: attachment_id,
            sappcast_app_build_changelog: params[:changelog]
          },
          sappcast_track: params[:track],
          status: 'draft'
        }

        build_request.body = build_data.to_json

        response = make_request(build_uri, build_request)
        build_result = JSON.parse(response.body)
        
        UI.success("Successfully created app build entry with ID: #{build_result['id']}")
        build_result['id']
      end

      def self.verify_url(url)
        uri = URI.parse(url)
        return uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      rescue URI::InvalidURIError
        return false
      end

      def self.extract_app_info(zip_file_path)
        UI.message("Extracting app info from zip file...")
        
        Zip::File.open(zip_file_path) do |zip_file|
          # Find the .app directory in the zip
          app_entry = zip_file.glob('*.app/Contents/Info.plist').first
          
          unless app_entry
            UI.user_error!("No .app bundle found in zip file")
            return nil
          end
          
          # Read the plist content
          plist_content = app_entry.get_input_stream.read
          info_plist = Plist.parse_xml(plist_content)
          
          {
            build_version: info_plist['CFBundleShortVersionString'],
            build_number: info_plist['CFBundleVersion'].to_i,
            min_system_version: info_plist['LSMinimumSystemVersion']
          }
        end
      rescue => e
        UI.error("Failed to extract app info: #{e.message}")
        nil
      end

      private

      def self.make_request(uri, request, read_timeout: 30)
        response = Net::HTTP.start(uri.hostname, uri.port, 
          use_ssl: uri.scheme == 'https',
          read_timeout: read_timeout,
          open_timeout: 10
        ) do |http|
          http.request(request)
        end

        unless response.is_a?(Net::HTTPSuccess)
          error_message = begin
            JSON.parse(response.body)['message']
          rescue
            response.body
          end
          UI.user_error!("Request failed: #{response.code} - #{error_message}")
        end

        response
      end
    end
  end
end
