//
//  ViewController.swift
//  OddCircleAnimation
//
//  Created by aryzae on 2019/02/01.
//  Copyright © 2019 aryzae. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var circleGraphView: CircleLineGraphView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        circleGraphView.setPercentage(70)
    }

    @IBAction func touchUpInsideStartButton(_ sender: UIButton) {
        circleGraphView.show(animated: true)
    }
}

final class CircleLineGraphView: UIView {
    private enum CircleType {
        case background
        case main(percentage: CGFloat)
    }
    private enum CircleAlignment {
        case outside
        case center
        case inside

        var coefficient: CGFloat {
            switch self {
            case .outside: return 1
            case .center:  return 2
            case .inside:  return 3
            }
        }
    }
    // MARK: - Properties
    // MARK: Public
    // MARK: Private
    private let mainLineWidth: CGFloat = 6
    var backgroundLineWidth: CGFloat {
        return mainLineWidth / 2
    }
    private(set) var percentage: CGFloat = 0
    private(set) var duration: CFTimeInterval = 1.5
    private let circleAlignment: CircleAlignment = .inside

    // MARK: - Public method
    func setPercentage(_ percentage: Int) {
        self.percentage = CGFloat(percentage)
    }

    func show(animated: Bool) {
        remove()

        let backgroundCirclePath = makeCirclePath(type: .background).cgPath
        let backgroundCircleLayer = makeLayer(path: backgroundCirclePath, lineWidth: backgroundLineWidth, lineColor: .gray)
        layer.addSublayer(backgroundCircleLayer)

        let mainCirclepath = makeCirclePath(type: .main(percentage: percentage)).cgPath
        let mainCircleLayer = makeLayer(path: mainCirclepath, lineWidth: mainLineWidth, lineColor: .red)
        layer.addSublayer(mainCircleLayer)

        if animated {
            startAnimation(mainCircleLayer)
        }
    }

    func remove() {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }

    // MARK: - Private method
    private func calculationAngle(from degree: CGFloat) -> CGFloat {
        // 90度を0地点とし、角度を計算
        return (degree - 90) * CGFloat.pi / 180
    }

    private func makeCirclePath(type: CircleType) -> UIBezierPath {
        let boundsCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height)
        switch type {
        case .background:
            let backgroundRadius = (radius - backgroundLineWidth * circleAlignment.coefficient) / 2
            return UIBezierPath(arcCenter: boundsCenter, radius: backgroundRadius, startAngle: calculationAngle(from: 0), endAngle: calculationAngle(from: 360), clockwise: true)
        case .main(let percentage):
            let mainRadius = (radius - mainLineWidth) / 2
            let degree = 360 * percentage / 100
            return UIBezierPath(arcCenter: boundsCenter, radius: mainRadius, startAngle: calculationAngle(from: 0), endAngle: calculationAngle(from: degree), clockwise: true)
        }
    }

    private func makeLayer(path: CGPath, lineWidth: CGFloat, lineColor: UIColor, fillColor: UIColor = .clear) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = path
        layer.strokeColor = lineColor.cgColor
        layer.lineWidth = lineWidth
        layer.fillColor = fillColor.cgColor
        return layer
    }

    private func startAnimation(_ layer: CAShapeLayer) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: animation.keyPath)
    }
}
