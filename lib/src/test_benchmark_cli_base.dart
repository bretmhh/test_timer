import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';

class TestResult {
  final String id;
  final String name;
  final String suite;
  final int duration;

  TestResult({
    required this.id,
    required this.name,
    required this.suite,
    required this.duration,
  });

  String get displayName => '$suite: $name';
}

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'path',
      abbr: 'p',
      help: 'Path to the Flutter project',
      defaultsTo: '.',
    )
    ..addOption(
      'top',
      abbr: 't',
      help: 'Number of slowest tests to show',
      defaultsTo: '10',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show help information',
      negatable: false,
    )
    ..addMultiOption(
      'args',
      help: 'Additional arguments to pass to flutter test',
    );
  late ArgResults argResults;
  try {
    argResults = parser.parse(args);
  } catch (e) {
    print('Error parsing arguments: $e');
    print(parser.usage);
    exit(1);
  }

  if (argResults['help'] as bool) {
    print('Test Benchmark CLI - Benchmark your Flutter/Dart tests\n');
    print('Usage: test_benchmark_cli [options]\n');
    print(parser.usage);
    return;
  }

  final projectPath = argResults['path'] as String;
  final topCount = int.tryParse(argResults['top'] as String) ?? 10;
  final additionalArgs = argResults['args'] as List<String>;

  print('🚀 Starting test benchmark...\n');

  final stopwatch = Stopwatch()..start();

  // Build flutter test command
  final testArgs = ['test', '--machine', ...additionalArgs];

  final process = await Process.start(
    'flutter',
    testArgs,
    workingDirectory: projectPath,
    runInShell: true,
  );

  final testResults = <TestResult>[];
  final testNames = <String, String>{}; // testID -> test name
  final suiteNames = <String, String>{}; // suiteID -> suite name
  final testToSuite = <String, String>{}; // testID -> suiteID

  var totalTests = 0;
  var failedTests = 0;

  process.stdout.transform(utf8.decoder).transform(LineSplitter()).listen((
    line,
  ) {
    try {
      final event = jsonDecode(line);
      final type = event['type'] as String?;

      switch (type) {
        case 'suite':
          final suiteID = event['suite']['id'].toString();
          final suitePath = event['suite']['path'] as String?;
          if (suitePath != null) {
            suiteNames[suiteID] = suitePath
                .split('/')
                .last
                .replaceAll('.dart', '');
          }
          break;

        case 'group':
          // Groups can contain nested test structure info
          break;

        case 'testStart':
          final testID = event['test']['id'].toString();
          final testName = event['test']['name'] as String;
          final suiteID = event['test']['suiteID'].toString();

          testNames[testID] = testName;
          testToSuite[testID] = suiteID;
          break;

        case 'testDone':
          totalTests++;
          final testID = event['testID'].toString();
          final result = event['result'] as String;
          final time = (event['time'] as num?)?.toInt() ?? 0;

          if (result == 'success') {
            final testName = testNames[testID] ?? 'Unknown Test';
            final suiteID = testToSuite[testID] ?? '';
            final suiteName = suiteNames[suiteID] ?? 'Unknown Suite';

            testResults.add(
              TestResult(
                id: testID,
                name: testName,
                suite: suiteName,
                duration: time,
              ),
            );
          } else {
            failedTests++;
          }
          break;
      }
    } catch (e) {
      // Skip malformed JSON lines
    }
  });

  // Handle stderr for any error messages
  process.stderr.transform(utf8.decoder).listen((line) {
    if (line.trim().isNotEmpty) {
      stderr.writeln('Flutter test error: $line');
    }
  });

  final exitCode = await process.exitCode;
  stopwatch.stop();

  if (exitCode != 0) {
    print('❌ Tests failed with exit code: $exitCode');
    exit(exitCode);
  }

  // Calculate statistics
  final successfulTests = testResults.length;
  final totalTime = stopwatch.elapsedMilliseconds;
  final testDurations = testResults.map((t) => t.duration).toList();
  final totalTestTime = testDurations.fold(0, (a, b) => a + b);
  final averageTime = successfulTests > 0 ? totalTestTime / successfulTests : 0;

  // Sort by duration (longest first)
  testResults.sort((a, b) => b.duration.compareTo(a.duration));

  // Display results
  print('\n📊 Test Benchmark Results');
  print('=' * 50);
  print('Overall execution time: ${_formatDuration(totalTime)}');
  print('Total tests run: $totalTests');
  print('Successful tests: $successfulTests');
  if (failedTests > 0) {
    print('Failed tests: $failedTests');
  }
  print('Average test time: ${_formatDuration(averageTime.round())}');

  if (testResults.isNotEmpty) {
    print('\n🐌 Slowest Tests (Top ${topCount.clamp(1, testResults.length)}):');
    print('-' * 50);

    for (int i = 0; i < topCount && i < testResults.length; i++) {
      final test = testResults[i];
      final rank = (i + 1).toString().padLeft(2);
      final duration = _formatDuration(test.duration).padLeft(8);
      print('$rank. $duration - ${test.displayName}');
    }

    // Show some quick stats
    final fastest = testResults.last;
    final slowest = testResults.first;

    print('\n📈 Stats:');
    print(
      'Slowest test: ${_formatDuration(slowest.duration)} - ${slowest.displayName}',
    );
    print(
      'Fastest test: ${_formatDuration(fastest.duration)} - ${fastest.displayName}',
    );
    print(
      'Speed difference: ${(slowest.duration / fastest.duration).toStringAsFixed(1)}x',
    );
  } else {
    print('\n⚠️  No test timing data collected');
  }

  print('\n✨ Benchmark complete!');
}

String _formatDuration(int milliseconds) {
  if (milliseconds < 1000) {
    return '${milliseconds}ms';
  } else if (milliseconds < 60000) {
    return '${(milliseconds / 1000).toStringAsFixed(1)}s';
  } else {
    final minutes = milliseconds ~/ 60000;
    final seconds = ((milliseconds % 60000) / 1000).toStringAsFixed(1);
    return '${minutes}m ${seconds}s';
  }
}
