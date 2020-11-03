//
//  LKRulerPicker.swift
//  LKRulerPicker
//
//  Created by Lal Krishna on 17/10/20.
//  Copyright © 2020 Lal Krishna. All rights reserved.
//

import UIKit

public protocol LKRulerPickerDataSource: class {
    func rulerPicker(_ picker: LKRulerPicker, titleForIndex index: Int) -> String?
    func rulerPicker(_ picker: LKRulerPicker, highlightTitleForIndex index: Int) -> String?
}

public protocol LKRulerPickerDelegate: class {
    func rulerPicker(_ picker: LKRulerPicker, didSelectItemAtIndex index: Int)
}

public struct LKRulerPickerConfiguration {
    
    public enum Direction {
        case horizontal, vertical
    }
    
    public enum Alignment {
        case start, end
    }
    
    public struct Metrics {
        
        public var minimumValue: Int = 10
        public var defaultValue: Int = 55 {
            didSet {
                defaultValue = max(maximumValue, min(defaultValue, minimumValue))
            }
        }
        public var maximumValue: Int = 150
        public var divisions = 10
        
        public var fullLineSize: CGFloat = 40
        public var midLineSize: CGFloat = 28
        public var smallLineSize: CGFloat = 18
        
        var midDivision: Int {
            divisions / 2
        }
       
        public init(minimumValue: Int = 10, defaultValue: Int = 55, maximumValue: Int = 150, divisions: Int = 10, fullLineSize: CGFloat = 40, midLineSize: CGFloat = 28, smallLineSize: CGFloat = 18) {
            self.minimumValue = minimumValue
            self.defaultValue = defaultValue
            self.maximumValue = maximumValue
            self.divisions = divisions
            self.fullLineSize = fullLineSize
            self.midLineSize = midLineSize
            self.smallLineSize = smallLineSize
        }
        
        func value(for type: LineHeight) -> CGFloat {
            switch type {
            case .full: return fullLineSize
            case .mid: return midLineSize
            case .small: return smallLineSize
            }
        }
        
        func lineType(index: Int) -> LineHeight {
            if index % divisions == 0 {
                return .full
            } else if index % midDivision == 0 {
                return .mid
            } else {
                return .small
            }
        }
        
        public static var `default`: Metrics { Metrics() }
        
//        static var inches: Metrics {
//            Metrics(divisions: 12)
//        }
    }
    
    public var scrollDirection: Direction = .horizontal
    public var alignment: Alignment = .end
    public var lineSpacing: CGFloat = 10
    public var lineAndLabelSpacing: CGFloat = 6
    public var metrics: Metrics = .default
    
    static var `default`: LKRulerPickerConfiguration { LKRulerPickerConfiguration() }
    
    public init(scrollDirection: LKRulerPickerConfiguration.Direction = .horizontal, alignment: LKRulerPickerConfiguration.Alignment = .end, lineSpacing: CGFloat = 10, lineAndLabelSpacing: CGFloat = 6, metrics: LKRulerPickerConfiguration.Metrics = .default) {
        self.scrollDirection = scrollDirection
        self.alignment = alignment
        self.lineSpacing = lineSpacing
        self.lineAndLabelSpacing = lineAndLabelSpacing
        self.metrics = metrics
    }
    
    
    fileprivate var isHorizontal: Bool {
        scrollDirection == .horizontal
    }
}

enum LineHeight {
    case full, mid, small
    
    init(index: Int, divisions: Int, midDivision: Int) {
        if index % divisions == 0 {
            self = .full
        } else if index % midDivision == 0 {
            self = .mid
        } else {
            self = .small
        }
    }
}

public class LKRulerPicker: UIView {
    
    // MARK: - Public properties
    
    public var configuration: LKRulerPickerConfiguration = .default {
        didSet {
            configureCollectionView()
        }
    }
    
    public var font: UIFont = .systemFont(ofSize: 12)
    public var highlightFont: UIFont = .boldSystemFont(ofSize: 14) {
        didSet {
            indicatorLabel.font = highlightFont
            indicatorLabel.textColor = highlightTextColor
        }
    }
    
    public var highlightLineColor: UIColor = .black {
        didSet { indicatorLine.backgroundColor = highlightLineColor }
    }
    
    public var highlightTextColor: UIColor = .black {
        didSet { indicatorLabel.textColor = highlightTextColor }
    }
    
    public weak var dataSource: LKRulerPickerDataSource?
    
    public weak var delegate: LKRulerPickerDelegate?
    
    public var highlightedIndex: Int = 0
    
    // MARK: - UI Elements
    
    private lazy var collectionView: UICollectionView = {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
//        $0.delegate = self
//        $0.dataSource = self
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()))
    
    private lazy var indicatorLabel: UILabel = {
        $0.font = highlightFont
        $0.textColor = highlightLineColor
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    private lazy var indicatorLabelGradientView = {
        return $0
    }(UIView())
    private lazy var indicatorLabelGradient = CAGradientLayer()
    
    private lazy var indicatorLine: UIView = {
        $0.backgroundColor = highlightLineColor
        return $0
    }(UIView())
        
    private var layout: UICollectionViewFlowLayout {
        collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    private var itemSize: CGSize = CGSize(width: 1, height: 1)
    
    private var cellWidthIncludingSpacing: CGFloat {
        if configuration.isHorizontal {
            return itemSize.width + layout.minimumLineSpacing
        } else {
            return itemSize.height + layout.minimumInteritemSpacing
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
        
        indicatorLabel.sizeToFit()
        if configuration.isHorizontal {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: bounds.midX, bottom: 0, right: bounds.midX)
            indicatorLabel.center.x = collectionView.center.x
            indicatorLine.center.x = collectionView.center.x
            indicatorLine.frame.size = CGSize(width: 2, height: configuration.metrics.fullLineSize)
            switch configuration.alignment {
            case .start:
                indicatorLine.frame.origin.y = 0
                indicatorLabel.frame.origin.y = indicatorLine.frame.origin.y + indicatorLine.frame.size.height + configuration.lineAndLabelSpacing
            case .end:
                indicatorLine.frame.origin.y = bounds.height - indicatorLine.frame.size.height
                indicatorLabel.frame.origin.y = indicatorLine.frame.origin.y - configuration.lineAndLabelSpacing - indicatorLabel.frame.size.height
            }
            
        } else {
            collectionView.contentInset = UIEdgeInsets(top: bounds.midY, left: 0, bottom: bounds.midY, right: 0)
            indicatorLabel.center.y = collectionView.center.y
            indicatorLine.center.y = collectionView.center.y
            indicatorLine.frame.size = CGSize(width: configuration.metrics.fullLineSize, height: 2)
            switch configuration.alignment {
            case .start:
                indicatorLine.frame.origin.x = 0
                indicatorLabel.frame.origin.x = configuration.metrics.fullLineSize + configuration.lineAndLabelSpacing
            case .end:
                indicatorLabel.frame.origin.x = configuration.metrics.fullLineSize + configuration.lineAndLabelSpacing
                indicatorLine.frame.origin.x = indicatorLabel.frame.origin.x
                
            }
        }
        indicatorLabelGradientView.frame = indicatorLabel.frame
        indicatorLabelGradient.frame = indicatorLabelGradientView.bounds
        
        let bgColor = backgroundColor ?? UIColor.white
        let tranparentWhite = bgColor.withAlphaComponent(0)
        indicatorLabelGradient.colors = [tranparentWhite.cgColor, bgColor.cgColor, bgColor.cgColor, tranparentWhite.cgColor]
        
    }
    
    private func commonInit() {
        addSubview(collectionView)
        addSubview(indicatorLabelGradientView)
        addSubview(indicatorLabel)
        addSubview(indicatorLine)
        indicatorLabelGradientView.layer.insertSublayer(indicatorLabelGradient, at: 0)
        collectionView.register(LKRulerLineCell.self, forCellWithReuseIdentifier: LKRulerLineCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: collectionView.superview!.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: collectionView.superview!.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: collectionView.superview!.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: collectionView.superview!.rightAnchor),
        ])
        configureCollectionView()
    }
    
    public func reload() {
        collectionView.reloadData()
    }
    
    // MARK: - Config
    
    private func configureCollectionView() {
        layout.minimumLineSpacing = configuration.lineSpacing
        layout.minimumInteritemSpacing = configuration.lineSpacing
        if configuration.isHorizontal {
            layout.scrollDirection = .horizontal
//            layout.itemSize = CGSize(width: 1, height: bounds.height)
        } else {
            layout.scrollDirection = .vertical
//            layout.itemSize = CGSize(width: bounds.width, height: 1)
        }
        scrollToValue(configuration.metrics.defaultValue, animated: false)
    }
    
    func scrollToValue(_ value: Int, animated: Bool = true) {
//        setNeedsLayout()
//        layoutIfNeeded()
        layoutSubviews()
        collectionView.reloadData()
        collectionView.layoutSubviews()
        
        let offset: CGPoint
        let selected = CGFloat(value - configuration.metrics.minimumValue)
        if configuration.isHorizontal {
            offset = CGPoint(x: selected * cellWidthIncludingSpacing - collectionView.contentInset.left, y: 0)
        } else {
            offset = CGPoint(x: 0, y: selected * cellWidthIncludingSpacing - collectionView.contentInset.top)
        }
        
        DispatchQueue.main.async {
            self.collectionView.setContentOffset(offset, animated: animated)
        }
    }
}

extension LKRulerPicker: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        configuration.metrics.maximumValue - configuration.metrics.minimumValue + 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LKRulerLineCell.identifier, for: indexPath) as! LKRulerLineCell // swiftlint:disable:this force_cast
        cell.tintColor = tintColor
        cell.numberLabel.font = font
        cell.numberLabel.text = dataSource?.rulerPicker(self, titleForIndex: indexPath.row)
        cell.configure(indexPath.row, using: configuration)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if configuration.isHorizontal {
            itemSize = CGSize(width: 1, height: bounds.height)
        } else {
            itemSize = CGSize(width: bounds.width, height: 1)
        }
        return itemSize
    }
}

extension LKRulerPicker: UIScrollViewDelegate {
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        var offset = targetContentOffset.pointee
        let contentInset = scrollView.contentInset
        
        if configuration.isHorizontal {
            let roundedIndex = round((offset.x + contentInset.left) / cellWidthIncludingSpacing)
            offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - contentInset.left, y: -contentInset.top)
        } else {
            let roundedIndex = round((offset.y + contentInset.top) / cellWidthIncludingSpacing)
            offset = CGPoint(x: -contentInset.left, y: roundedIndex * cellWidthIncludingSpacing - contentInset.top)
        }
        
        targetContentOffset.pointee = offset
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let contentInset = scrollView.contentInset
        let index: Int
        let itemsCount = collectionView.numberOfItems(inSection: 0) - 1
        if configuration.isHorizontal {
            let roundedIndex = round((offset.x + contentInset.left) / cellWidthIncludingSpacing)
            index = max(0, min(itemsCount, Int(roundedIndex)))
        } else {
            let roundedIndex = round((offset.y + contentInset.top) / cellWidthIncludingSpacing)
            index = max(0, min(itemsCount, Int(roundedIndex)))
        }
        highlightedIndex = index
        indicatorLabel.text = dataSource?.rulerPicker(self, highlightTitleForIndex: index)
        indicatorLabel.sizeToFit()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let indexPath = collectionView.indexPathForItem(at: visiblePoint) {
            // let _ = collectionView.cellForItem(at: indexPath) as? LKRulerLineCell
            delegate?.rulerPicker(self, didSelectItemAtIndex: indexPath.row)
        }
    }
    
}

private class LKRulerLineCell: UICollectionViewCell {
    
    static let identifier = String(describing: LKRulerLineCell.self)
    
    fileprivate lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = tintColor
        return view
    }()
    
    fileprivate lazy var numberLabel: UILabel = {
        $0.textColor = tintColor
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    override var tintColor: UIColor! {
        didSet {
            numberLabel.textColor = tintColor
            lineView.backgroundColor = tintColor
        }
    }
    
    var lineHeight: LineHeight = .full
    
    var config: LKRulerPickerConfiguration = .default
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = false
        
        addSubview(lineView)
        addSubview(numberLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    private func updateHeight(for type: LineHeight, config: LKRulerPickerConfiguration) {
        var origin: CGPoint
        var size: CGSize
        size = .init(width: bounds.width, height: config.metrics.value(for: type))
        switch config.alignment {
        case .start:
            origin = .zero
        case .end:
            origin = .init(x: 0, y: bounds.height - size.height)
        }
        if !config.isHorizontal {
            origin = .zero
            size = .init(width: config.metrics.value(for: type), height: bounds.height)
        }
        lineView.frame = .init(origin: origin, size: size)
    }
    
    func configure(_ index: Int, using config: LKRulerPickerConfiguration) {
        lineHeight = LineHeight(index: index, divisions: config.metrics.divisions, midDivision: config.metrics.midDivision)
        updateHeight(for: lineHeight, config: config)
        
        numberLabel.sizeToFit()

        if config.isHorizontal {
            numberLabel.center.x = lineView.center.x
            switch config.alignment {
            case .start:
                numberLabel.frame.origin.y = lineView.frame.origin.y + lineView.frame.size.height + config.lineAndLabelSpacing
            case .end:
                numberLabel.frame.origin.y = bounds.height - lineView.frame.size.height - config.lineAndLabelSpacing - numberLabel.frame.size.height
            }
        } else {
            numberLabel.center.y = lineView.center.y
            numberLabel.frame.origin.x = config.metrics.fullLineSize + config.lineAndLabelSpacing
        }
    }
}
