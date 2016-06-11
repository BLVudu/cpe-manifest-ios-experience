# NextGen Extras

## Table of Contents
1. [Overview](#Overview)
2. [License](#License)
3. [Diagrams](#Diagrams)
4. [Getting Started](#Getting-Started)


## Overview
NextGen Extras is an _enhanced_ 'extras' experience around user owned content. This reference library is built to allow implementators to accelerate their NextGen Extras iPad Tablet implementation.

## License
This codebase is open-source under the Apache 2.0 license. See [LICENSE](LICENSE)

## Diagrams
### iPad & Android Tablet Flowchart
A high-level flowchart on how the library operates when embedded in a partner retailer's app.
![Architectural Flowchart](./Docs/NextGen_Flowchart.svg?raw=true)

### Data binding + UI layers
The reference code for iPad & Android Tablets is being built to be modular; e.g. a partner retailer can choose to use just the manifest-to-native data-binding layer and/or the UI layer. Each layer is customizable by retailer is they choose to do so.
![Architectural Layers](./Docs/NextGen_Data_and_UI_Layers.svg?raw=true)

### iOS CocoaPods Library Diagram
A iOS specific architecture diagram.
![iOS Architecture Diagram](./Docs/NextGen_iOS_Library_Diagram.svg?raw=true)

## Getting Started
### Dependency Management
[CocoaPods](https://guides.cocoapods.org/using/getting-started.html) can be used to easily set this library up in an existing iOS application.

#### iPad Dependency Licenses
[iPad Dependency Licenses](./Docs/Licenses/opensource-licenses.html)  
See: ./Docs/Licenses/opensource-licenses.html

### Installation
#### Podfile
To integrate NextGen Extras into your Xcode project using [CocoaPods](https://guides.cocoapods.org/using/getting-started.html), specify it in your Podfile:
```
pod 'NextGenExtras'
```