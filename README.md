# LKRulerPicker

Customizable Ruler picker

# Installation

### Swift Package Manager

**File / Swift Packages / Add Package Dependency...** and enter package repository URL: ```https://github.com/lalkrishna/LKRulerPicker``` and follow the instructions.

### Manually
Clone the repo and Drag and drop to your project (it will be added as a package)
OR
You can just copy the file: Sources/LKRulerPicker/[LKRulerPicker.swift](https://github.com/lalkrishna/LKRulerPicker/blob/main/Sources/LKRulerPicker/LKRulerPicker.swift "LKRulerPicker.swift")

# Usage

### Via Storyboard
Create UIView
Assign class and Module as: **LKRulerPicker**

### Programatically

```swift
import LKRulerPicker

private lazy var heightPicker: LKRulerPicker = {
    $0.dataSource = self
    $0.delegate = self
    $0.tintColor = UIColor.black.withAlphaComponent(0.5)
    $0.highlightLineColor = .black
    $0.highlightTextColor = .black
    return $0
}(LKRulerPicker())

view.addSubview(heightPicker)
```


# Configuration

```swift
let heightMetrics = LKRulerPickerConfiguration.Metrics(
            minimumValue: 50,
            defaultValue: 150,
            maximumValue: 300,
            divisions: 5,
            fullLineSize: 38,
            midLineSize: 28,
            smallLineSize: 28)
heightPicker.configuration = LKRulerPickerConfiguration(
            scrollDirection: .vertical,
            alignment: .start,
            metrics: heightMetrics,
            isHapticsEnabled: false)
```

### Delegation/Datasource
```swift
public protocol LKRulerPickerDataSource: class {
    func rulerPicker(_ picker: LKRulerPicker, titleForIndex index: Int) -> String?
    func rulerPicker(_ picker: LKRulerPicker, highlightTitleForIndex index: Int) -> String?
}

public protocol LKRulerPickerDelegate: class {
    func rulerPicker(_ picker: LKRulerPicker, didSelectItemAtIndex index: Int)
}
```

