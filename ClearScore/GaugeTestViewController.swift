//
//  GaugeTestViewController.swift
//  ClearScore
//
//  Created by Luke Van In on 2020/03/19.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import UIKit


final class GaugeTestViewController: UIViewController {
    
    private let gaugeView = GaugeView()
    private let valueLabel = UILabel()
    private let sliderView = UISlider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let initialValue = CGFloat(0.5)
        let minValue = CGFloat(0.0)
        let maxValue = CGFloat(1.0)
        sliderView.minimumValue = Float(minValue)
        sliderView.maximumValue = Float(maxValue)
        sliderView.value = Float(initialValue)
        gaugeView.minValue = minValue
        gaugeView.maxValue = maxValue
        gaugeView.value = initialValue
        valueLabel.font = UIFont.boldSystemFont(ofSize: 64)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        gaugeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gaugeView)
        view.addSubview(valueLabel)
        view.addSubview(sliderView)
        NSLayoutConstraint.activate([
            gaugeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gaugeView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            gaugeView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            gaugeView.heightAnchor.constraint(equalTo: gaugeView.widthAnchor),

            valueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            sliderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sliderView.topAnchor.constraint(equalTo: gaugeView.bottomAnchor, constant: 64),
            sliderView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -64),
            ])
        sliderView.addTarget(self, action: #selector(onSliderValueChanged), for: [.valueChanged])
    }
    
    @objc func onSliderValueChanged(sender: UISlider) {
        updateGauge()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateGauge()
    }
    
    private func updateGauge() {
        gaugeView.value = CGFloat(sliderView.value)
        let t = sliderView.value / (sliderView.maximumValue - sliderView.minimumValue)
        valueLabel.text = String(format: "%0.2f", t)
        valueLabel.textColor = UIColor.red.blend(with: UIColor.green, by: CGFloat(t))
    }
}
