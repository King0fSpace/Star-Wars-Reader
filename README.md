# News Reader App

The News Reader App is a basic iOS app that pulls articles and images from an API. The app was created for practice and assessment purposes, without the use of any third-party frameworks.

## Features

The following features have been implemented in the app:

- Use of `Combine` framework for API calls, data handling, and error handling.
- Use of `Codable` protocol for automatic JSON to model object mapping.
- Asynchronous downloading of large images without affecting UI framerates.
- Re-use of inflight network requests to eliminate unnecessary data use 
- Error handling for 404 responses from image APIs that sets retry limits and next-try time intervals.
- Caching of JSON and image data for offline viewing mode.
- Checking of JSON object timestamps for content and image freshness for re-downloading purposes.
- Custom navigation controller push and pop animations using the `UIViewControllerAnimatedTransitioning` class.
- Dynamic animations during article scrolling.
- Use of `DiffableDataSource` and `Prefetch` delegate methods.

## Installation

To install and run the app, follow these steps:

1. Clone the repository to your local machine:
2. Open the `Star Wars Reader.xcodeproj` file in Xcode.
3. Build and run the app in the simulator or on a physical device.

## Usage

When the app is launched, it will display a list of articles retrieved from the API. The user can scroll through the list and tap on an article to view the full article details. The app also supports offline viewing mode if data has been previously cached.

## Credits

The News Reader App was created by Long Le for practice and assessment purposes.

## License

This project is licensed under the MIT License - see the `LICENSE.md` file for details.
