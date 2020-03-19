//
//  GaugeView.swift
//  ClearScore
//
//  Created by Luke Van In on 2020/03/19.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import UIKit


final class GaugeView: UIView {
    
    var minValue: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var maxValue: CGFloat = 1.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var value: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var startColor: UIColor = .red {
        didSet {
            setNeedsLayout()
        }
    }
    
    var endColor: UIColor = .green {
        didSet {
            setNeedsLayout()
        }
    }
    
    var outlineColor: UIColor = .black {
        didSet {
            setNeedsLayout()
        }
    }
    
    var trackInset: CGFloat = 8 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var trackWidth: CGFloat = 16 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private let outlineLayer = CAShapeLayer()
    private let trackLayer = CAGradientLayer()
    private let trackMaskLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        isOpaque = false
        backgroundColor = .clear

        trackMaskLayer.lineCap = .round
        trackMaskLayer.strokeColor = UIColor.black.cgColor
        trackMaskLayer.fillColor = UIColor.clear.cgColor

        trackLayer.type = .conic
        trackLayer.mask = trackMaskLayer
        trackLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        trackLayer.endPoint = CGPoint(x: 0.5, y: 0)

        outlineLayer.lineWidth = 1
        outlineLayer.fillColor = UIColor.clear.cgColor
        
        layer.addSublayer(trackLayer)
        layer.addSublayer(outlineLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = min(bounds.width, bounds.height) * 0.5
        let size = CGSize(
            width: radius * 2,
            height: radius * 2
        )
        let region = CGRect(
            origin: CGPoint(
                x: (bounds.width - size.width) * 0.5,
                y: (bounds.height - size.height) * 0.5
            ),
            size: size
        )
        
        // Outline
        let outlinePath = UIBezierPath(ovalIn: bounds)
        outlineLayer.frame = region
        outlineLayer.strokeColor = outlineColor.cgColor
        outlineLayer.path = outlinePath.cgPath
        
        // Track
        trackLayer.frame = region
        trackLayer.colors = [startColor.cgColor, endColor.cgColor]
        
        // Track Mask
        let s = value / (maxValue - minValue)
        let o = CGFloat(-0.24)
        let t = min(max(s, 0.001), 0.98)
        let trackRadiusMax = radius - trackInset
        let trackRadiusMid = trackRadiusMax - (trackWidth * 0.5)
        let maskPath = UIBezierPath(
            arcCenter: CGPoint(
                x: region.width * 0.5,
                y: region.height * 0.5
            ),
            radius: trackRadiusMid,
            startAngle: o * .pi * 2.0,
            endAngle: (o + t) * .pi * 2.0,
            clockwise: true
        )
        trackMaskLayer.frame = region
        trackMaskLayer.lineWidth = trackWidth
        trackMaskLayer.path = maskPath.cgPath
    }
}
