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

### ios test

```sh
[bundle exec] fastlane ios test
```

Run tests

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Deploy to App Store

### ios build

```sh
[bundle exec] fastlane ios build
```

Create a new build without uploading

### ios fetch_feedback

```sh
[bundle exec] fastlane ios fetch_feedback
```

Fetch TestFlight feedback and screenshots

### ios fetch_feedback_v2

```sh
[bundle exec] fastlane ios fetch_feedback_v2
```

Fetch TestFlight data using improved Spaceship methods

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
