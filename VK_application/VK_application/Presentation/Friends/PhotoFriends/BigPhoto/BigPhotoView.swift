//
//  BigPhotoView.swift
//  VK_application
//
//  Created by Сергей Чумовских  on 02.08.2021.
//

import UIKit

class BigPhotoView: UIView {
    
    private var leftView: UIImageView = {
        let leftView = UIImageView()
        leftView.isHidden = true
        leftView.translatesAutoresizingMaskIntoConstraints = false
        leftView.contentMode = .scaleAspectFit
        return leftView
    }()
    private var visibleView: UIImageView = {
        let visibleView = UIImageView()
        visibleView.translatesAutoresizingMaskIntoConstraints = false
        visibleView.contentMode = .scaleAspectFit
        return visibleView
    }()
    private var rightView: UIImageView = {
        let rightView = UIImageView()
        rightView.isHidden = true
        rightView.translatesAutoresizingMaskIntoConstraints = false
        rightView.contentMode = .scaleAspectFit
        return rightView
    }()
    private var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = ""
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()
    private var panGesture: UIPanGestureRecognizer?
    private var beginCenterXVisibleView: CGFloat = 0
    private var beginCenterXRightView: CGFloat = 0
    private var beginCenterXLeftView: CGFloat = 0
    private let scale = CGAffineTransform(scaleX: 0.85, y: 0.85)
    var namePhoto: [String] = []
    var photoes: [String] = []
    var visibleIndex: Int = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setViews()
        setGesture()
        setPhotos()
        beginCenterXVisibleView = visibleView.center.x
        beginCenterXRightView = rightView.center.x
        beginCenterXLeftView = leftView.center.x
    }
    
    private func setViews() {
        addSubview(leftView)
        addSubview(rightView)
        addSubview(visibleView)
        addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            visibleView.widthAnchor.constraint(equalTo: self.widthAnchor),
            visibleView.heightAnchor.constraint(equalTo: self.widthAnchor),
            visibleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            visibleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            leftView.widthAnchor.constraint(equalTo: self.widthAnchor),
            leftView.heightAnchor.constraint(equalTo: self.widthAnchor),
            leftView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            leftView.trailingAnchor.constraint(equalTo: visibleView.leadingAnchor, constant: -15),
            
            rightView.widthAnchor.constraint(equalTo: self.widthAnchor),
            rightView.heightAnchor.constraint(equalTo: self.widthAnchor),
            rightView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            rightView.leadingAnchor.constraint(equalTo: visibleView.trailingAnchor, constant: 15),
            
            nameLabel.topAnchor.constraint(equalTo: visibleView.topAnchor, constant: -40),
            nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 40),
            nameLabel.widthAnchor.constraint(equalToConstant: 370)
        ])
    }
    
    private func setGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        guard let gesture = panGesture else {
            print("panGesture is not initial")
            return
        }
        visibleView.addGestureRecognizer(gesture)
    }
    
    private func setPhotos() {
        guard
            !photoes.isEmpty,
            photoes.count > visibleIndex && visibleIndex >= 0
        else {
            print("Error index for visible view")
            return
        }
        visibleView.image = UIImage(named: photoes[visibleIndex])
        leftView.image = UIImage(named: photoes[earlyIndex()])
        rightView.image = UIImage(named: photoes[nextIndex()])
        nameLabel.text = namePhoto[visibleIndex]
        visibleView.isUserInteractionEnabled = true
    }
    
    @IBAction private func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.visibleView)
        if let visibleViewRecogniser = recognizer.view {
            visibleViewRecogniser.center.x = visibleViewRecogniser.center.x + translation.x
            leftView.center.x = leftView.center.x + translation.x
            rightView.center.x = rightView.center.x + translation.x
            
            rightView.isHidden = false
            leftView.isHidden = false
            
            visibleView.transform = scale
            rightView.transform = scale
            leftView.transform = scale
        }
        recognizer.setTranslation(.zero, in: self.visibleView)
        if recognizer.state == .ended {
            let offset = beginCenterXVisibleView - visibleView.center.x
            if offset > 100 {
                startAnimate(.left)
            } else if offset < -100 {
                startAnimate(.right)
            } else {
                startAnimate(.revert)
            }
        }
    }
    
    private func nextIndex() -> Int {
        let lastIndex = photoes.count - 1
        if lastIndex == visibleIndex {
            return 0
        } else {
            return visibleIndex + 1
        }
    }
    
    private func earlyIndex() -> Int {
        let lastIndex = photoes.count - 1
        if visibleIndex == 0 {
            return lastIndex
        } else {
            return visibleIndex - 1
        }
    }
    
   private func transformAnimate() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: [.curveEaseOut,],
            animations: { [unowned self] in
                self.visibleView.transform = .identity
                self.rightView.transform = .identity
                self.leftView.transform = .identity
                if self.nameLabel.alpha == 0 {
                    self.nameLabel.alpha = 1
                } else {
                    self.nameLabel.alpha = 0
                }
            }, completion: { _ in
                self.nameLabel.alpha = 1
                self.labelAlphaAnimate()
            })
    }
    
    private func labelAlphaAnimate() {
        UIView.animate(
            withDuration: 1,
            delay: 3,
            options: [.curveEaseOut,],
            animations: { [unowned self] in
                self.nameLabel.alpha = 0
            })
    }
    
    private func startAnimate(_ direction: DirectionAnimation) {
        visibleView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            switch direction {
            case .revert:
                self.visibleView.center.x = self.beginCenterXVisibleView
                self.leftView.center.x = self.beginCenterXLeftView
                self.rightView.center.x = self.beginCenterXRightView
                self.transformAnimate()
            case .left:
                self.visibleView.center.x = self.beginCenterXLeftView
                self.rightView.center.x = self.beginCenterXVisibleView
                self.visibleIndex = self.nextIndex()
                self.transformAnimate()
            case .right:
                self.visibleView.center.x = self.beginCenterXRightView
                self.leftView.center.x = self.beginCenterXVisibleView
                self.visibleIndex = self.earlyIndex()
                self.transformAnimate()
            }
        } completion: { _ in
            self.visibleView.isUserInteractionEnabled = true
            self.visibleView.center.x = self.beginCenterXVisibleView
            self.leftView.center.x = self.beginCenterXLeftView
            self.rightView.center.x = self.beginCenterXRightView
            self.setPhotos()
        }
    }
    
    enum DirectionAnimation {
        case left
        case right
        case revert
    }
    
}
