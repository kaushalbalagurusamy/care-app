fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios verify_api

```sh
[bundle exec] fastlane ios verify_api
```

Verify the API key against App Store Connect without changing anything

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Increment the TestFlight build number, archive, and upload to TestFlight

### ios upload_ipa

```sh
[bundle exec] fastlane ios upload_ipa
```

Upload an already exported IPA to TestFlight

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
