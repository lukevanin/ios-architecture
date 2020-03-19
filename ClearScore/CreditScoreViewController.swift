//
//  Views.swift
//  ClearScore
//
//  Created by Luke Van In on 2020/03/19.
//  Copyright © 2020 lukevanin. All rights reserved.
//

import UIKit


protocol CreditScorePresenter: AnyObject {
    typealias Observer = (CreditScoreViewModel) -> Void
    var observer: Observer? { get set }
    func refreshCreditScore()
}


final class CreditScoreViewController: UIViewController {

    private var trackMinColor: UIColor = .red
    private var trackMaxColor: UIColor = .green
    private let topLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "credit-score-heading-label"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "credit-score-total-label"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    private let scoreValueLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "credit-score-value-label"
        label.font = UIFont.boldSystemFont(ofSize: 64)
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    private let scoreGaugeView: GaugeView = {
        let view = GaugeView()
        view.accessibilityIdentifier = "credit-score-gauge"
        view.outlineColor = .gray
        return view
    }()
    private let presenter: CreditScorePresenter
    
    init(presenter: CreditScorePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        scoreGaugeView.translatesAutoresizingMaskIntoConstraints = false
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreValueLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreGaugeView)
        view.addSubview(topLabel)
        view.addSubview(scoreValueLabel)
        view.addSubview(bottomLabel)
        NSLayoutConstraint.activate([
            scoreGaugeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreGaugeView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scoreGaugeView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            scoreGaugeView.heightAnchor.constraint(equalTo: scoreGaugeView.widthAnchor),
            
            scoreValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreValueLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topLabel.bottomAnchor.constraint(equalTo: scoreValueLabel.topAnchor),
            
            bottomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomLabel.topAnchor.constraint(equalTo: scoreValueLabel.bottomAnchor),
        ])
        scoreGaugeView.minValue = 0
        scoreGaugeView.maxValue = 1
        scoreGaugeView.value = 0
        topLabel.alpha = 0
        bottomLabel.alpha = 0
        scoreValueLabel.text = "--"
        scoreValueLabel.alpha = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.observer = { [weak self] viewModel in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.setViewModel(viewModel, animated: true)
            }
        }
        presenter.refreshCreditScore()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.observer = nil
    }
    
    private func setViewModel(_ viewModel: CreditScoreViewModel, animated: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.scoreGaugeView.startColor = self.trackMinColor
            self.scoreGaugeView.endColor = self.trackMaxColor
            self.scoreGaugeView.minValue = CGFloat(viewModel.minScoreValue)
            self.scoreGaugeView.maxValue = CGFloat(viewModel.maxScoreValue)
            self.scoreGaugeView.value = CGFloat(viewModel.scoreValue)
            #warning("TODO: Localise top label")
            self.topLabel.text = "Your credit score is"
            self.topLabel.alpha = 1.0
            self.scoreValueLabel.text = viewModel.scoreValueLabel
            self.scoreValueLabel.alpha = 1.0
            self.scoreValueLabel.textColor = self.trackMinColor.blend(
                with: self.trackMaxColor,
                by: CGFloat(viewModel.scoreValue) / CGFloat(viewModel.maxScoreValue - viewModel.minScoreValue)
            )
            self.bottomLabel.text = "out of \(viewModel.maxScoreValue)"
            self.bottomLabel.alpha = 1.0
        }
    }
}
