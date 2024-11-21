# Changelog
All notable changes to this project will be documented in this file.

Since version 2.0.0, the format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed
### Fixed
### Removed

## [2.0.0] - 2024-11-21
- COVERAGE:  95.50% -- 106/111 lines in 6 files
- BRANCH COVERAGE:  84.00% -- 21/25 branches in 6 files
- 44.83% documented
### Added
- Tests lifted from Rails v8.0 test suite.
- `ActiveSupport::LoggerSilence`
- `ActiveSupport::IsolatedExecutionState`
### Changed
- Now loads even in Rails 8
  - fully replaced logging tooling that ships with all versions of Rails >= v5.2 on Ruby 2.7+
### Fixed
- Compatibility with Rails > v5.2 and < v7.1
  - proved by Appraisals-based CI matrix covering all supported versions of Rails & Ruby

## [1.0.1] - 2024-10-10
- COVERAGE:  51.32% -- 39/76 lines in 6 files
- BRANCH COVERAGE:   5.56% -- 1/18 branches in 6 files
- 55.56% documented
### Fixed
- Typo in internal file name (non-breaking, just annoying/confusing)

## [1.0.0] - 2024-10-10
- COVERAGE:  51.32% -- 39/76 lines in 6 files
- BRANCH COVERAGE:   5.56% -- 1/18 branches in 6 files
- 55.56% documented
### Added
- Initial release
