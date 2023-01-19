// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.8

import 'package:coverage/coverage.dart' as coverage;
import 'package:meta/meta.dart';
import 'package:vm_service/vm_service.dart' as vm_service;

import '../base/file_system.dart';
import '../base/io.dart';
import '../base/process.dart';
import '../globals.dart' as globals;
import '../vmservice.dart';

import 'test_device.dart';
import 'watcher.dart';

/// A class that's used to collect coverage data during tests.
class CoverageCollector extends TestWatcher {
  CoverageCollector({this.libraryPredicate, this.verbose = true, @required this.packagesPath});

  final bool verbose;
  final String packagesPath;
  Map<String, coverage.HitMap> _globalHitmap;
  bool Function(String) libraryPredicate;

  @override
  Future<void> handleFinishedTest(TestDevice testDevice) async {
    _logMessage('Starting coverage collection');
    await collectCoverage(testDevice);
  }

  void _logMessage(String line, { bool error = false }) {
    if (!verbose) {
      return;
    }
    if (error) {
      globals.printError(line);
    } else {
      globals.printTrace(line);
    }
  }

  void _addHitmap(Map<String, coverage.HitMap> hitmap) {
    if (_globalHitmap == null) {
      _globalHitmap = hitmap;
    } else {
      _globalHitmap.merge(hitmap);
    }
  }

  /// Collects coverage for an isolate using the given `port`.
  ///
  /// This should be called when the code whose coverage data is being collected
  /// has been run to completion so that all coverage data has been recorded.
  ///
  /// The returned [Future] completes when the coverage is collected.
  Future<void> collectCoverageIsolate(Uri observatoryUri) async {
    assert(observatoryUri != null);
    _logMessage('collecting coverage data from $observatoryUri...');
    final Map<String, dynamic> data = await collect(observatoryUri, libraryPredicate);
    if (data == null) {
      throw Exception('Failed to collect coverage.');
    }
    assert(data != null);

    _logMessage('($observatoryUri): collected coverage data; merging...');
    _addHitmap(await coverage.HitMap.parseJson(
      data['coverage'] as List<Map<String, dynamic>>,
      packagesPath: packagesPath,
      checkIgnoredLines: true,
    ));
    _logMessage('($observatoryUri): done merging coverage data into global coverage map.');
  }

  /// Collects coverage for the given [Process] using the given `port`.
  ///
  /// This should be called when the code whose coverage data is being collected
  /// has been run to completion so that all coverage data has been recorded.
  ///
  /// The returned [Future] completes when the coverage is collected.
  Future<void> collectCoverage(TestDevice testDevice) async {
    assert(testDevice != null);

    Map<String, dynamic> data;

    final Future<void> processComplete = testDevice.finished.catchError(
      (Object error) => throw Exception(
          'Failed to collect coverage, test device terminated prematurely with '
          'error: ${(error as TestDeviceException).message}.'),
      test: (Object error) => error is TestDeviceException,
    );

    final Future<void> collectionComplete = testDevice.observatoryUri
      .then((Uri observatoryUri) {
        _logMessage('collecting coverage data from $testDevice at $observatoryUri...');
        return collect(observatoryUri, libraryPredicate)
          .then<void>((Map<String, dynamic> result) {
            if (result == null) {
              throw Exception('Failed to collect coverage.');
            }
            _logMessage('Collected coverage data.');
            data = result;
          });
      });

    await Future.any<void>(<Future<void>>[ processComplete, collectionComplete ]);
    assert(data != null);

    _logMessage('Merging coverage data...');
    _addHitmap(await coverage.HitMap.parseJson(
      data['coverage'] as List<Map<String, dynamic>>,
      packagesPath: packagesPath,
      checkIgnoredLines: true,
    ));
    _logMessage('Done merging coverage data into global coverage map.');
  }

  /// Returns formatted coverage data once all coverage data has been collected.
  ///
  /// This will not start any collection tasks. It us up to the caller of to
  /// call [collectCoverage] for each process first.
  String finalizeCoverage({
    String Function(Map<String, coverage.HitMap> hitmap) formatter,
    coverage.Resolver resolver,
    Directory coverageDirectory,
  }) {
    if (_globalHitmap == null) {
      return null;
    }
    if (formatter == null) {
      resolver ??= coverage.Resolver(packagesPath: packagesPath);
      final String packagePath = globals.fs.currentDirectory.path;
      final List<String> reportOn = coverageDirectory == null
          ? <String>[globals.fs.path.join(packagePath, 'lib')]
          : <String>[coverageDirectory.path];
      formatter = (Map<String, coverage.HitMap> hitmap) => hitmap
          .formatLcov(resolver, reportOn: reportOn, basePath: packagePath);
    }
    final String result = formatter(_globalHitmap);
    _globalHitmap = null;
    return result;
  }

  bool collectCoverageData(String coveragePath, { bool mergeCoverageData = false, Directory coverageDirectory }) {
    final String coverageData = finalizeCoverage(
      coverageDirectory: coverageDirectory,
    );
    _logMessage('coverage information collection complete');
    if (coverageData == null) {
      return false;
    }

    final File coverageFile = globals.fs.file(coveragePath)
      ..createSync(recursive: true)
      ..writeAsStringSync(coverageData, flush: true);
    _logMessage('wrote coverage data to $coveragePath (size=${coverageData.length})');

    const String baseCoverageData = 'coverage/lcov.base.info';
    if (mergeCoverageData) {
      if (!globals.fs.isFileSync(baseCoverageData)) {
        _logMessage('Missing "$baseCoverageData". Unable to merge coverage data.', error: true);
        return false;
      }

      if (globals.os.which('lcov') == null) {
        String installMessage = 'Please install lcov.';
        if (globals.platform.isLinux) {
          installMessage = 'Consider running "sudo apt-get install lcov".';
        } else if (globals.platform.isMacOS) {
          installMessage = 'Consider running "brew install lcov".';
        }
        _logMessage('Missing "lcov" tool. Unable to merge coverage data.\n$installMessage', error: true);
        return false;
      }

      final Directory tempDir = globals.fs.systemTempDirectory.createTempSync('flutter_tools_test_coverage.');
      try {
        final File sourceFile = coverageFile.copySync(globals.fs.path.join(tempDir.path, 'lcov.source.info'));
        final RunResult result = globals.processUtils.runSync(<String>[
          'lcov',
          '--add-tracefile', baseCoverageData,
          '--add-tracefile', sourceFile.path,
          '--output-file', coverageFile.path,
        ]);
        if (result.exitCode != 0) {
          return false;
        }
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    }
    return true;
  }

  @override
  Future<void> handleTestCrashed(TestDevice testDevice) async { }

  @override
  Future<void> handleTestTimedOut(TestDevice testDevice) async { }
}

Future<FlutterVmService> _defaultConnect(Uri serviceUri) {
  return connectToVmService(
      serviceUri, compression: CompressionOptions.compressionOff, logger: globals.logger,);
}

Future<Map<String, dynamic>> collect(Uri serviceUri, bool Function(String) libraryPredicate, {
  bool waitPaused = false,
  String debugName,
  Future<FlutterVmService> Function(Uri) connector = _defaultConnect,
  @visibleForTesting bool forceSequential = false,
}) async {
  final FlutterVmService vmService = await connector(serviceUri);
  final Map<String, dynamic> result = await _getAllCoverage(vmService.service, libraryPredicate, forceSequential);
  await vmService.dispose();
  return result;
}

Future<Map<String, dynamic>> _getAllCoverage(
  vm_service.VmService service,
  bool Function(String) libraryPredicate,
  bool forceSequential,
) async {
  final vm_service.Version version = await service.getVersion();
  final bool reportLines = (version.major == 3 && version.minor >= 51) || version.major > 3;
  final vm_service.VM vm = await service.getVM();
  final List<Map<String, dynamic>> coverage = <Map<String, dynamic>>[];
  for (final vm_service.IsolateRef isolateRef in vm.isolates) {
    if (isolateRef.isSystemIsolate) {
      continue;
    }
    vm_service.ScriptList scriptList;
    try {
      scriptList = await service.getScripts(isolateRef.id);
    } on vm_service.SentinelException {
      continue;
    }

    final List<Future<void>> futures = <Future<void>>[];
    final Map<String, vm_service.Script> scripts = <String, vm_service.Script>{};
    final Map<String, vm_service.SourceReport> sourceReports = <String, vm_service.SourceReport>{};
    // For each ScriptRef loaded into the VM, load the corresponding Script and
    // SourceReport object.

    for (final vm_service.ScriptRef script in scriptList.scripts) {
      final String libraryUri = script.uri;
      if (!libraryPredicate(libraryUri)) {
        continue;
      }
      final String scriptId = script.id;
      final Future<void> getSourceReport = service.getSourceReport(
        isolateRef.id,
        <String>['Coverage'],
        scriptId: scriptId,
        forceCompile: true,
        reportLines: reportLines ? true : null,
      )
      .then((vm_service.SourceReport report) {
        sourceReports[scriptId] = report;
      });
      if (forceSequential) {
        await null;
      }
      futures.add(getSourceReport);
      if (reportLines) {
        continue;
      }
      final Future<void> getObject = service
        .getObject(isolateRef.id, scriptId)
        .then((vm_service.Obj response) {
          final vm_service.Script script = response as vm_service.Script;
          scripts[scriptId] = script;
        });
      futures.add(getObject);
    }
    await Future.wait(futures);
    _buildCoverageMap(scripts, sourceReports, coverage, reportLines);
  }
  return <String, dynamic>{'type': 'CodeCoverage', 'coverage': coverage};
}

// Build a hitmap of Uri -> Line -> Hit Count for each script object.
void _buildCoverageMap(
  Map<String, vm_service.Script> scripts,
  Map<String, vm_service.SourceReport> sourceReports,
  List<Map<String, dynamic>> coverage,
  bool reportLines,
) {
  final Map<String, Map<int, int>> hitMaps = <String, Map<int, int>>{};
  for (final String scriptId in sourceReports.keys) {
    final vm_service.SourceReport sourceReport = sourceReports[scriptId];
    for (final vm_service.SourceReportRange range in sourceReport.ranges) {
      final vm_service.SourceReportCoverage coverage = range.coverage;
      // Coverage reports may sometimes be null for a Script.
      if (coverage == null) {
        continue;
      }
      final vm_service.ScriptRef scriptRef = sourceReport.scripts[range.scriptIndex];
      final String uri = scriptRef.uri;

      hitMaps[uri] ??= <int, int>{};
      final Map<int, int> hitMap = hitMaps[uri];
      final List<int> hits = coverage.hits;
      final List<int> misses = coverage.misses;
      final List<dynamic> tokenPositions = scripts[scriptRef.id]?.tokenPosTable;
      // The token positions can be null if the script has no lines that may be
      // covered. It will also be null if reportLines is true.
      if (tokenPositions == null && !reportLines) {
        continue;
      }
      if (hits != null) {
        for (final int hit in hits) {
          final int line =
              reportLines ? hit : _lineAndColumn(hit, tokenPositions)[0];
          final int current = hitMap[line] ?? 0;
          hitMap[line] = current + 1;
        }
      }
      if (misses != null) {
        for (final int miss in misses) {
          final int line =
              reportLines ? miss : _lineAndColumn(miss, tokenPositions)[0];
          hitMap[line] ??= 0;
        }
      }
    }
  }
  hitMaps.forEach((String uri, Map<int, int> hitMap) {
    coverage.add(_toScriptCoverageJson(uri, hitMap));
  });
}

// Binary search the token position table for the line and column which
// corresponds to each token position.
// The format of this table is described in https://github.com/dart-lang/sdk/blob/main/runtime/vm/service/service.md#script
List<int> _lineAndColumn(int position, List<dynamic> tokenPositions) {
  int min = 0;
  int max = tokenPositions.length;
  while (min < max) {
    final int mid = min + ((max - min) >> 1);
    final List<int> row = (tokenPositions[mid] as List<dynamic>).cast<int>();
    if (row[1] > position) {
      max = mid;
    } else {
      for (int i = 1; i < row.length; i += 2) {
        if (row[i] == position) {
          return <int>[row.first, row[i + 1]];
        }
      }
      min = mid + 1;
    }
  }
  throw StateError('Unreachable');
}

// Returns a JSON hit map backward-compatible with pre-1.16.0 SDKs.
Map<String, dynamic> _toScriptCoverageJson(String scriptUri, Map<int, int> hitMap) {
  final Map<String, dynamic> json = <String, dynamic>{};
  final List<int> hits = <int>[];
  hitMap.forEach((int line, int hitCount) {
    hits.add(line);
    hits.add(hitCount);
  });
  json['source'] = scriptUri;
  json['script'] = <String, dynamic>{
    'type': '@Script',
    'fixedId': true,
    'id': 'libraries/1/scripts/${Uri.encodeComponent(scriptUri)}',
    'uri': scriptUri,
    '_kind': 'library',
  };
  json['hits'] = hits;
  return json;
}
