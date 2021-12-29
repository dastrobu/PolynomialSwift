# PolynomialSwift

[![Swift Version](https://img.shields.io/badge/swift-5.5-blue.svg)](https://swift.org) 
![Platform](https://img.shields.io/badge/platform-macOS-lightgray.svg)
[![documentation](https://github.com/dastrobu/PolynomialSwift/raw/master/docs/badge.svg?sanitize=true)](https://dastrobu.github.io/PolynomialSwift/)

Polynomials and Piecewise Polynomials in Swift.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Table of Contents

- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
  - [Cocoa Pods](#cocoa-pods)
  - [Dependencies](#dependencies)
- [Features](#features)
  - [Planned](#planned)
- [Docs](#docs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Installation

### Swift Package Manager

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/dastrobu/PolynomialSwift.git", from: "0.1.0"),
    ]
)
```

### Cocoa Pods
Make sure a valid deployment target is setup in the Podfile and add

    pod 'PolynomialSwift', '~> 0'

### Dependencies
Depends on Accelerate and hence only runs on macOS

## Features
 - Fast polynomial evaluation (employing [Accelerate](https://developer.apple.com/documentation/accelerate) framework)
 - Derivatives

### Planned
 - Integrals
 - Root finding
 
## Docs

Read the generated [docs](https://dastrobu.github.io/PolynomialSwift/).