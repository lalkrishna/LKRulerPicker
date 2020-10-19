//
//  ViewController.swift
//  Example
//
//  Created by Lal Krishna on 18/10/20.
//

import UIKit
import LKRulerPicker

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var weightPicker: LKRulerPicker!
    
    private lazy var heightPicker: LKRulerPicker = {
        let heightMetrics = LKRulerPickerConfiguration.Metrics(
            minimumValue: 100,
            defaultValue: 155,
            maximumValue: 250,
            divisions: 5,
            fullLineSize: 40,
            midLineSize: 32,
            smallLineSize: 32)
        $0.configuration = LKRulerPickerConfiguration(scrollDirection: .vertical, alignment: .start, metrics: heightMetrics)
        $0.dataSource = self
        $0.tintColor = UIColor.black.withAlphaComponent(0.5)
        $0.highlightLineColor = .black
        $0.highlightTextColor = .black
        return $0
    }(LKRulerPicker())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHeightPicker()
//        configureWeightPicker()
        weightPicker.dataSource = self
        weightPicker.backgroundColor = .red
    }
    
    private func addHeightPicker() {
        view.addSubview(heightPicker)
        heightPicker.translatesAutoresizingMaskIntoConstraints = false
//        heightPicker.backgroundColor = .red
        
        
        NSLayoutConstraint.activate([
            heightPicker.topAnchor.constraint(equalTo: heightPicker.superview!.topAnchor, constant: 200),
            heightPicker.leftAnchor.constraint(equalTo: heightPicker.superview!.leftAnchor),
            heightPicker.widthAnchor.constraint(equalToConstant: 120),
            heightPicker.heightAnchor.constraint(equalToConstant: 200)
        ])
        
//        heightPicker.layoutSubviews()
//        heightPicker.reload()
//        heightPicker.configuration = heightPicker.configuration
    }

    private func configureWeightPicker() {
        let weightMetrics = LKRulerPickerConfiguration.Metrics(
            minimumValue: 35,
            defaultValue: 55,
            maximumValue: 150,
            divisions: 5,
            fullLineSize: 40,
            midLineSize: 32,
            smallLineSize: 32)
        weightPicker.configuration = LKRulerPickerConfiguration(scrollDirection: .horizontal, alignment: .end, metrics: weightMetrics)
        weightPicker.font = UIFont(name: "HelveticaNeue-UltraLight", size: 12)!
        weightPicker.highlightFont = UIFont(name: "AmericanTypewriter-Bold", size: 24)!
        weightPicker.dataSource = self
    }
    
    // MARK: - Actions
    
    @IBAction func didTapPrintButton(_ sender: UIButton) {
        let weightText = rulerPicker(weightPicker, highlightTitleForIndex: weightPicker.highlightedIndex)
        let heightText = rulerPicker(heightPicker, highlightTitleForIndex: heightPicker.highlightedIndex)
        debugPrint("\(weightText ?? "nil"), \(heightText ?? "nil")")
    }
    
}

extension ViewController: LKRulerPickerDataSource {
    func rulerPicker(_ picker: LKRulerPicker, titleForIndex index: Int) -> String? {
        guard index % picker.configuration.metrics.divisions == 0 else { return nil }
        switch picker {
        case heightPicker:
            return "\(picker.configuration.metrics.minimumValue + index) cm"
        case weightPicker:
            return "\(picker.configuration.metrics.minimumValue + index)"
        default:
            return "N/A"
        }
        
    }
    
    func rulerPicker(_ picker: LKRulerPicker, highlightTitleForIndex index: Int) -> String? {
        switch picker {
        case heightPicker:
            return "\(picker.configuration.metrics.minimumValue + index) cm"
        case weightPicker:
            return "\(picker.configuration.metrics.minimumValue + index) KG"
        default:
            return "N/A"
        }
    }
}

