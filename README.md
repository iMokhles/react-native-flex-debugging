# react-native-flex-debugging
React-Native a set of in-app debugging and exploration tools for (iOS)

## Getting started

`$ npm install react-native-flex-debugging --save`\
or\
`$ yarn add react-native-flex-debugging`

### Link library (if below 0.60)

`$ react-native link react-native-flex-debugging`

## ios

1. cd to ios
2. run `pod init` (if only Podfile has not been generated in ios folder)
3. (if you are running RN below 0.61 ONLY) add `pod 'FLEX', '4.1.1'` to pod file
4. run `pod install` (you have to delete the app on the simulator/device and run `react-native run-ios` again)


## Code Usage
```javascript
import FlexDebugging from 'react-native-flex-debugging';

// Show Explorer
FlexDebugging.showExplorer();

// Hide Explorer
FlexDebugging.hideExplorer();

// Toggle Explorer
FlexDebugging.toggleExplorer();

```
## Thanks & Credits
[FLEXTool](https://github.com/FLEXTool/FLEX)
