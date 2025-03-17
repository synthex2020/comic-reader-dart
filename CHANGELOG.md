### 4.1.6

- Removed Encryption pattern
- Added background isolate processing to epub download 
- Changed epub and html files working memory to cache and temporary directory 
- Compressed epub and html files on save 
- Set up background processing to download epub file 

### 4.1.5

- Fixed the infinite loading problem
- Now HTML is being read from file instead from a string in memory 

### 4.1.4

- Added a file compression function on saving epub to disk
- Added a dynamic solution to handling large epub files in memory using cache and local storage 
- Fixed orientation bug that came as a result of storage solution implementation 

### 4.1.3

- Added Zoom for android


### 4.1.2 

- Removed fitted widget 
- Calculated a set length for title length and added ellipses when relevant 

### 4.1.1 

- Improved memory management 

### 4.1.0

- Added a book icon to the loading widget 
- Reduced the size of numerical text in the loading widget 
- Reduced the thickness of the loading bar in the loading widget

### 4.0.9

- Reduced spacing between images by enforcing existing space in CSS using !important

### 4.0.8

- Reduced the spacing between images to zero 

### 4.0.7
- Fixed text length with ellipses in truncation 
- Added multiple varied sizes in the title 

## 4.0.6

- Added a fitted box to adjust title size according the text length

## 4.0.5

- Fixed local storage issue

## 4.0.4

- Merge all pull requests

## 3.0.0
### Changed
- `metadata` file now saves as `mimetype` [pull#1](https://github.com/rbcprolabs/epubx.dart/pull/1) 
### Added
- Epub v3 support [dart-epub | pull#76](https://github.com/orthros/dart-epub/pull/76) 
- Doc comment [dart-epub | pull#80](https://github.com/orthros/dart-epub/pull/80) 

## 3.0.0-dev.3
### Changed
- At `EpubReader.{openBook, readBook}` first argument can be future (not before) 

## 3.0.0-dev.2
### Fixed
- Fixed null-safety bug

## 3.0.0-dev.1
### Added
- Null-safety migration
### Changed
- Upgrade all dependencies

## 2.1.0
### Fixed
- Version 3 EPUB's can have a null Table of Contents
- Updated `pedantic` analysis options

## 2.0.7
### Added
- Added example of using `epub` in a web page: `examples/web_ex`
### Fixed
- Fixed errors from pedantic analysis
### Changed
- Added pedantic analysis options

## 2.0.6
### Fixed
- Fixed Issue #35: File cannot be opened if its path is url-encoded in the manifest
- Updated `examples/dart_ex` to have a README as well as use a locally stored file.

## 2.0.5
### Changed
- Exposed `EpubChapterRef` to consumers.

## 2.0.4
### Fixed
- Merged pull request #45
    - Fixes pana hits to make code more readable

## 2.0.3
### Changed
- Raised `sdk` version constraint to 2.0.0
- Raised constraint on `async` to 3.0.0
### Fixed
- Merged pull request #40 by vblago. 
    - Fixes Undefined class 'XmlBuilder'

## 2.0.2
### Changed
- Lowered sdk version constraint to 2.0.0-dev.61.0

## 2.0.1
### Changed
- Formatted documents

## 2.0.0
### Added
- Added support for writing Epubs back to Byte Arrays
- Tests for writing Epubs

### Changed
- Epub Readers and Writers now have their == operator and hashCode get-er overridden

### Fixed
- Fixed an issue when reading EpubContentFileRef

## 1.3.2
### Changed
- Updates to Travis configuration and publishing

## 1.3.1
### Changed
- Updates to Travis configuration and publishing
### Removed
- Removed unused variable `FilePath` from `EpubBook` and `EpubBookRef`

## 1.3.0
### Added
- Package now supports Dart 2!
### Removed
- Removed support for Dart 1.2.21

## 1.2.10
### Fixed
- Merged pull request #15 from ShadowJonathan/dev. 
    - Fixes issue with parsing schema by removing `opf:` namespace

## 1.2.9
### Changed
- Ran code through `dartfmt` as per analysis by `pana`

## 1.2.8
### Added
- Added unit tests for Images
### Changed
- Updated dependencies

## 1.2.7
### Added
- Added upper limit of Dart version to 2.0.1

## 1.2.6
### Added
- Added Support for Dart 2.0

## 1.2.5
### Added
- A publish step in the travis deploy

## 1.2.4
### Changed
- EnumFromString no longer uses the `mirrors` package to make this Flutter compatible by @MostafaAyesh 

## 1.2.3
### Added
- This Changelog!

### Changed
- Author email

## 1.2.2
### Changed
- Dependencies were updated to more permissive versions by @jarontai

### Added
- Example by @jarontai
- More Entities and types are exported by @jarontai

### Fixed
- Issue with case sensitivity in switch statements from @jarontai
- Issue with Async Loops from @jarontai

## 1.2.1
### Fixed
- Made code in line with Dart styleguide
