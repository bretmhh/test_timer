<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

# Test Benchmark CLI

A powerful CLI tool for benchmarking Flutter/Dart test performance, inspired by Very Good CLI. 

## Features

- **📊 Comprehensive Test Metrics**: Measures total execution time, average test duration, and identifies the slowest tests
- **🏷️ Human-Readable Test Names**: Shows actual test names and suite information instead of cryptic test IDs
- **⚡ Performance Insights**: Highlights performance differences between fastest and slowest tests
- **🎯 Configurable Output**: Choose how many slowest tests to display
- **📁 Flexible Project Targeting**: Run benchmarks on any Flutter project path
- **🔧 Flutter Test Integration**: Seamlessly integrates with Flutter's test runner

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  test_benchmark_cli: ^1.0.0
```

Or activate globally:

```bash
dart pub global activate test_benchmark_cli
```

## Usage

### Basic usage
```bash
dart run test_benchmark_cli
```

### Show help
```bash
dart run test_benchmark_cli --help
```

### Show top 5 slowest tests
```bash
dart run test_benchmark_cli --top 5
```

### Run on specific project path
```bash
dart run test_benchmark_cli --path ./my_flutter_project
```

### Pass additional Flutter test arguments
```bash
dart run test_benchmark_cli --args="--coverage" --args="--reporter=json"
```

## Example Output

```
🚀 Starting test benchmark...

📊 Test Benchmark Results
==================================================
Overall execution time: 2.3s
Total tests run: 25
Successful tests: 25
Average test time: 45.2ms

🐌 Slowest Tests (Top 10):
--------------------------------------------------
 1.   324ms - widget_test: should render correctly with data
 2.   156ms - integration_test: full user flow test
 3.   89ms - unit_test: complex calculation test
 4.   67ms - widget_test: animation test
 5.   45ms - unit_test: async operation test
 ...

📈 Quick Stats:
Slowest test: 324ms - widget_test: should render correctly with data
Fastest test: 12ms - unit_test: simple validation test
Speed difference: 27.0x

✨ Benchmark complete!
```

## CLI Options

- `--path`, `-p`: Path to the Flutter project (default: current directory)
- `--top`, `-t`: Number of slowest tests to show (default: 10)
- `--args`: Additional arguments to pass to flutter test (can be used multiple times)
- `--help`, `-h`: Show help information

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Additional information
TODO
