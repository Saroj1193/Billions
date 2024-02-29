//
//  UserDefaultsManager.swift
//  FalconMessenger
//
//  Created by Roman Mizin on 8/12/18.
//  Copyright © 2018 Roman Mizin. All rights reserved.
//

import UIKit
import Firebase


let userDefaults = UserDefaultsManager()

class UserDefaultsManager: NSObject {
  
  fileprivate let defaults = UserDefaults.standard

	let chatLogDefaultFontSizeID = "chatLogDefaultFontSizeID"
  let authVerificationID = "authVerificationID"
  let changeNumberAuthVerificationID = "ChangeNumberAuthVerificationID"
  let selectedTheme = "SelectedTheme"
  let hasRunBefore = "hasRunBefore"
  let biometricType = "biometricType"
  let inAppNotifications = "In-AppNotifications"
  let inAppSounds = "In-AppSounds"
  let inAppVibration = "In-AppVibration"
  let biometricalAuth = "BiometricalAuth"
  let contactsContiniousSync = "ContactsContiniousSync"
  let contactsSyncronizationStatus = "ContactsSyncronizationStatus"
  let contactsCount = "ContactsCount"
  
  //updating
  func updateObject(for key: String, with data: Any?) {
    defaults.set(data, forKey: key)
    defaults.synchronize()
  }
  //

  //removing
  func removeObject(for key: String) {
    defaults.removeObject(forKey: key)
  }
  //
  
  //current state
  func currentStringObjectState(for key: String) -> String? {
    return defaults.string(forKey: key)
  }
  
  func currentIntObjectState(for key: String) -> Int? {
    return defaults.integer(forKey: key)
  }
  
  func currentBoolObjectState(for key: String) -> Bool {
    return defaults.bool(forKey: key)
  }

	func currentFloatObjectState(for key: String) -> Float {
		return defaults.float(forKey: key)
	}
  //
  
  //existence
  func isContactsCountExists() -> Bool {
    guard defaults.object(forKey: contactsCount) == nil else { return true }
    return false
  }
  //
  
  // other
  func configureInitialLaunch() {
    if defaults.bool(forKey: hasRunBefore) != true {
      do { try Auth.auth().signOut() } catch {}
      updateObject(for: hasRunBefore, with: true)
    }
    setDefaultsForSettings()
  }
  
  func setDefaultsForSettings() {
    
    if defaults.object(forKey: inAppNotifications) == nil {
      updateObject(for: inAppNotifications, with: true)
    }
    
    if defaults.object(forKey: inAppSounds) == nil {
      updateObject(for: inAppSounds, with: true)
    }
    
    if defaults.object(forKey: inAppVibration) == nil {
      updateObject(for: inAppVibration, with: true)
    }
    
    if defaults.object(forKey: biometricalAuth) == nil {
      updateObject(for: biometricalAuth, with: false)
    }
    
    if defaults.object(forKey: contactsContiniousSync) == nil {
      updateObject(for: contactsContiniousSync, with: true)
    }

  }
}


class TypingIndicatorView: UIView {
  
  /// This view's content size is equal to the main stack.
  override var intrinsicContentSize: CGSize {
    stack.intrinsicContentSize
  }
  
  private enum Constants {
    /// The width of each ellipsis dot.
    static let width: CGFloat = 5
    /// How long should the dot scaling animation last.
    static let scaleDuration: Double = 0.6
    /// How much should the dots scale as a multiplier of their original scale.
    static let scaleAmount: Double = 1.6
    /// How much time should pass between each dot scale animation.
    static let delayBetweenRepeats: Double = 0.9
  }
  
  private let receiverName: String
  
  /// The main stack view of this view. Holds the dot stack view and the text.
  private var stack: UIStackView!

  init(receiverName: String) {
    self.receiverName = receiverName
    super.init(frame: .zero)
    createView()
  }

  required init?(coder: NSCoder) {
    fatalError()
  }
  
  private func createView() {
    translatesAutoresizingMaskIntoConstraints = false
    
    // Create the main stack view
    stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.alignment = .center
    stack.spacing = 5

    // Create the dots
    let dots = makeDots()
    stack.addArrangedSubview(dots)
    addSubview(stack)
    
    // Create the text
    let typingIndicatorLabel = UILabel()
    typingIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
    stack.addArrangedSubview(typingIndicatorLabel)
    
    // Make sure the name of the user is bold
    let attributedString = NSMutableAttributedString(
      string: receiverName,
      attributes: [.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)])

    let isTypingString = NSAttributedString(
      string: " is typing",
      attributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)])

    attributedString.append(isTypingString)
    typingIndicatorLabel.attributedText = attributedString
    
    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor),
      stack.topAnchor.constraint(equalTo: topAnchor),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }

  func makeDot(animationDelay: Double) -> UIView {
    let view = UIView(frame: CGRect(
      origin: .zero,
      size: CGSize(width: Constants.width, height: Constants.width)))
    
    view.translatesAutoresizingMaskIntoConstraints = false
    view.widthAnchor.constraint(equalToConstant: Constants.width).isActive = true

    let circle = CAShapeLayer()
    // Create a circular path
    let path = UIBezierPath(
      arcCenter: .zero,
      radius: Constants.width / 2,
      startAngle: 0,
      endAngle: 2 * .pi,
      clockwise: true)
    circle.path = path.cgPath

    circle.frame = view.bounds
    circle.fillColor = UIColor.gray.cgColor

    view.layer.addSublayer(circle)
    
    // Add a scaling animation for each dot
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.duration = Constants.scaleDuration / 2
    animation.toValue = Constants.scaleAmount
    animation.isRemovedOnCompletion = false
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    animation.autoreverses = true
    
    // Add the scaling animation to a group. The groups duration is longer
    // than the duration of the scale animation. This means there will be a
    // delay in scaling between each repeat of the group.
    let animationGroup = CAAnimationGroup()
    animationGroup.animations = [animation]
    animationGroup.duration = Constants.scaleDuration + Constants.delayBetweenRepeats
    animationGroup.repeatCount = .infinity
    // Add a starting delay.
    animationGroup.beginTime = CACurrentMediaTime() + animationDelay

    circle.add(animationGroup, forKey: "pulse")

    return view
  }
  
  private func makeDots() -> UIView {
    // Create a stack view to hold the dots.
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.alignment = .bottom
    stack.spacing = 5
    
    stack.heightAnchor.constraint(equalToConstant: Constants.width).isActive = true
    
    let dots = (0..<3).map { i in
      // Delay the start of each subseqent dot scale animation by 0.3 seconds.
      makeDot(animationDelay: Double(i) * 0.3)
    }
    dots.forEach(stack.addArrangedSubview)
    return stack
  }


  
}
