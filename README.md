# wp_sparkling_appcast plugin

This fastlane plugin helps you distribute your macOS app updates using [WordPress's Sparkling Appcast plugin](https://github.com/Usiel/sparkling-appcast). It automates the process of uploading your app's zip file and creating the necessary entries for Sparkle's appcast.xml feed.

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-wp_sparkling_appcast`, add it to your project by running:

```bash
fastlane add_plugin wp_sparkling_appcast
```

### Requirements

- WordPress installation with the [Sparkling Appcast plugin](https://github.com/Usiel/sparkling-appcast)
- WordPress Application Password for authentication
- macOS app packaged as a zip file
- Sparkle framework integration in your app

## Example

Here's how to use this plugin in your Fastfile:

```ruby
lane :release do
  # First, create your app archive and zip it
  gym(
    scheme: "YourApp",
    export_method: "developer-id",
    output_directory: "build",
    output_name: "YourApp.zip"
  )

  # Upload to WordPress and create appcast entry
  wp_sparkling_appcast_upload(
    base_url: "https://your-wordpress-site.com",
    wp_user: "your-username",
    wp_application_pw: ENV["WP_APP_PASSWORD"],
    changelog: "## Changes\n- Fixed some bugs\n- Added new features",
    zip_file: "build/YourApp.zip",
    channel: 123
  )
end
```

### Parameters

| Key                | Description                                       | Type    | Required | Default                             |
| ------------------ | ------------------------------------------------- | ------- | -------- | ----------------------------------- |
| base_url           | Base URL of your WordPress installation           | String  | Yes      | -                                   |
| wp_user            | WordPress username for authentication             | String  | Yes      | -                                   |
| wp_application_pw  | WordPress application password for authentication | String  | Yes      | -                                   |
| build_version      | Version number of the build (e.g. 1.2.3)          | String  | No       | App bundle's build version          |
| build_number       | Build number                                      | Integer | No       | App bundle's build number           |
| min_system_version | Minimum system version required                   | String  | No       | App bundle's minimum system version |
| changelog          | Changelog for this version                        | String  | No       | ""                                  |
| zip_file           | Path to the zip file to upload                    | String  | Yes      | -                                   |
| channel            | channel ID for this build                         | Integer | Yes      | -                                   |

## Issues and Feedback

You are welcome to submit issues with feedback, feature requests, and bugs to this repository.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
