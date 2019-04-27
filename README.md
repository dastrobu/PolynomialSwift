# PolynomialSwift
Polynomials and Piecewise Polynomials in Swift.

## Table of Contents

  * [Installation](#installation)
     * [Swift Package Manager](#swift-package-manager)
     * [Cocoa Pods](#cocoa-pods)
     * [Dependencies](#dependencies)

## Installation

### Swift Package Manager
    dependencies: [
            .package(url: "https://github.com/dastrobu/PolynomialSwift.git", from: "0.1.0"),
        ],

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