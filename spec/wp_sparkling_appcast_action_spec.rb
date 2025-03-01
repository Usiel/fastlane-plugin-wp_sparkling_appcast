describe Fastlane::Actions::WpSparklingAppcastAction do
  let(:test_zip_path) { File.expand_path("../fixtures/TestApp.zip", __FILE__) }
  let(:valid_params) do
    {
      zip_file: test_zip_path,
      base_url: 'https://example.com',
      wp_user: 'testuser',
      wp_application_pw: 'testpass',
      channel: 'beta',
      changelog: 'Test changelog'
    }
  end

  before do
    # Create a test zip file with a mock Info.plist
    FileUtils.mkdir_p(File.dirname(test_zip_path))
    create_test_zip(test_zip_path)
  end

  after do
    FileUtils.rm_f(test_zip_path)
  end

  describe '#run' do
    it 'successfully processes valid parameters' do
      allow(Fastlane::Helper::WpSparklingAppcastHelper).to receive(:upload_zip).and_return(123)
      allow(Fastlane::Helper::WpSparklingAppcastHelper).to receive(:create_build_entry).and_return(456)
      
      result = Fastlane::Actions::WpSparklingAppcastAction.run(valid_params)
      
      expect(result).to eq({
        attachment_id: 123,
        build_id: 456
      })
    end
  end

  describe Fastlane::Helper::WpSparklingAppcastHelper do
    describe '.verify_url' do
      it 'accepts valid URLs' do
        expect(described_class.verify_url('https://example.com')).to be true
        expect(described_class.verify_url('http://example.com')).to be true
      end

      it 'rejects invalid URLs' do
        expect(described_class.verify_url('not-a-url')).to be false
        expect(described_class.verify_url('ftp://example.com')).to be false
      end
    end

    describe '.extract_app_info' do
      it 'extracts correct info from zip file' do
        result = described_class.extract_app_info(test_zip_path)
        
        expect(result).to include(
          build_version: '1.0.0',
          build_number: 1,
          min_system_version: '10.13'
        )
      end

      it 'handles missing zip file' do
        expect(described_class.extract_app_info('nonexistent.zip')).to be_nil
      end
    end
  end

  private

  def create_test_zip(zip_path)
    Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
      plist_content = <<~PLIST
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleShortVersionString</key>
          <string>1.0.0</string>
          <key>CFBundleVersion</key>
          <string>1</string>
          <key>LSMinimumSystemVersion</key>
          <string>10.13</string>
        </dict>
        </plist>
      PLIST
      
      zipfile.get_output_stream('TestApp.app/Contents/Info.plist') do |f|
        f.write(plist_content)
      end
    end
  end
end
