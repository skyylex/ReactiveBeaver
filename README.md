[![Build    Status](https://travis-ci.org/skyylex/ReactiveBeaver.svg?branch=master)](https://travis-ci.org/skyylex/ReactiveBeaver)

# ReactiveBeaver

A personal project to taste ReactiveCocoa (ReactiveObjc) for a parsing problem. The project is NOT production-ready.

ePub parser for iOS and OS X.
Core parts are designed to be reactive and are written in ReactiveCocoa.

### Usage
#### Standard

```objc

NSString *soucePath = ... /// path of the .zip or .epub file
NSString *destinationPath = ... /// destination folder to unarchive

self.parser = [RBParser parserWithSourcePath:sourcePath destinationPath:destinationPath];
[self.parser.startParsingWithCompletionBlock:^(RBEpub * _Nullable epub, NSError * _Nullable error) {
  /// process data here
}];

```
#### RFP
This type of usage is built on the reactive-functional approach (based on the ReactiveCocoa 2.0 framework)

```objc

[[[self.parser startCommand].executionSignals
  flattenMap:^(RACSignal *parsingSignal) {
      return parsingSignal;
  }]
 subscribeNext:^(RBEpub *epub) {
    /// do additional stuff with parsed epub data
 }
 error:^(NSError *error) {
    /// process error
 }];

NSString *soucePath = ... /// path of the .zip or .epub file
NSString *destinationPath = ... /// destination folder to unarchive

/// Start of the actual parsing
[[self.parser startCommand] execute:RACTuplePack(sourcePath, destinationPath)];
```

### License
##### Code
ReactiveBeaver code is available under the MIT license. See LICENSE for details.

##### Book sources
All sources and compile tools were get from https://github.com/IDPF/epub3-samples
Books are used only for testing purpose.
> Unless specified otherwise in the samples table, all samples are licensed under CC-BY-SA 3.0

### Contacts
yury.lapitsky@gmail.com
