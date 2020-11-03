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
        $0.dataSource = self
        $0.delegate = self
        $0.tintColor = UIColor.black.withAlphaComponent(0.5)
        $0.highlightLineColor = .black
        $0.highlightTextColor = .black
        return $0
    }(LKRulerPicker())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHeightPicker()
        configureWeightPicker()
//        weightPicker.dataSource = self
    }
    
    private func addHeightPicker() {
//        let _ = view
        view.addSubview(heightPicker)
        heightPicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            heightPicker.topAnchor.constraint(equalTo: heightPicker.superview!.topAnchor, constant: 200),
            heightPicker.leftAnchor.constraint(equalTo: heightPicker.superview!.leftAnchor),
            heightPicker.widthAnchor.constraint(equalToConstant: 120),
            heightPicker.heightAnchor.constraint(equalToConstant: 235)
        ])
        
//        heightPicker.layoutSubviews()
//        heightPicker.reload()
        heightPicker.layoutIfNeeded()
        
        let heightMetrics = LKRulerPickerConfiguration.Metrics(
            minimumValue: 50,
            defaultValue: 150,
            maximumValue: 300,
            divisions: 5,
            fullLineSize: 38,
            midLineSize: 28,
            smallLineSize: 28)
        heightPicker.configuration = LKRulerPickerConfiguration(scrollDirection: .vertical, alignment: .start, metrics: heightMetrics)
    }

    private func configureWeightPicker() {
        let weightMetrics = LKRulerPickerConfiguration.Metrics(
            minimumValue: 0,
            defaultValue: 50,
            maximumValue: 250,
            divisions: 10,
            fullLineSize: 40,
            midLineSize: 32,
            smallLineSize: 22)
        weightPicker.configuration = LKRulerPickerConfiguration(scrollDirection: .horizontal, alignment: .end, metrics: weightMetrics)
        weightPicker.font = UIFont(name: "AmericanTypewriter-Bold", size: 12)!
        weightPicker.highlightFont = UIFont(name: "AmericanTypewriter-Bold", size: 18)!
        weightPicker.dataSource = self
        weightPicker.delegate = self
    }
    
    // MARK: - Actions
    
    @IBAction func didTapPrintButton(_ sender: UIButton) {
        let weightText = rulerPicker(weightPicker, highlightTitleForIndex: weightPicker.highlightedIndex)
        let heightText = rulerPicker(heightPicker, highlightTitleForIndex: heightPicker.highlightedIndex)
        label.text = "Weight: \(weightText ?? "nil"), Height: \(heightText ?? "nil")"
    }
    
}

extension ViewController: LKRulerPickerDelegate {
    func rulerPicker(_ picker: LKRulerPicker, didSelectItemAtIndex index: Int) {
        label.text = rulerPicker(picker, highlightTitleForIndex: index)
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
            fatalError("Handler picker")
        }
        
    }
    
    func rulerPicker(_ picker: LKRulerPicker, highlightTitleForIndex index: Int) -> String? {
        switch picker {
        case heightPicker:
            return "\(picker.configuration.metrics.minimumValue + index) cm"
        case weightPicker:
            return "\(picker.configuration.metrics.minimumValue + index) KG"
        default:
            fatalError("Handler picker")
        }
    }
}
