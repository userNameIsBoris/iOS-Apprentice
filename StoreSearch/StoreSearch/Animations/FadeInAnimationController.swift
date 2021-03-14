//
//  FadeInAnimationController.swift
//  StoreSearch
//
//  Created by Борис on 11.03.2021.
//

import UIKit

class FadeInAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.4
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
    let time = transitionDuration(using: transitionContext)

    transitionContext.containerView.addSubview(toView)
    toView.alpha = 0

    UIView.animate(
      withDuration: time,
      animations: { toView.alpha = 1 }) { finished in
      transitionContext.completeTransition(finished)
    }
  }
}
