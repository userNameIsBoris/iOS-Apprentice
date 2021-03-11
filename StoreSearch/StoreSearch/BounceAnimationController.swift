//
//  BounceAnimationController.swift
//  StoreSearch
//
//  Created by Борис on 11.03.2021.
//

import UIKit

class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.4
  }

  func animateTransition( using transitionContext: UIViewControllerContextTransitioning) {
    if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to), let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
      let containerView = transitionContext.containerView
      toView.frame = transitionContext.finalFrame(for: toViewController)
      containerView.addSubview(toView)
      toView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

      UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .calculationModeCubic, animations: {
        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.334) {
          toView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }

        UIView.addKeyframe(withRelativeStartTime: 0.666, relativeDuration: 0.333) {
          toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
      }) { finished in
        transitionContext.completeTransition(finished)
      }
    }
  }
}
