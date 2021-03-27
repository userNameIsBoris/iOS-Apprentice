//
//  FadeOutAnimationController.swift
//  StoreSearch
//
//  Created by Boris Ezhov on 11.03.2021.
//

import UIKit

class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.4
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
    let time = transitionDuration(using: transitionContext)

    UIView.animate(
      withDuration: time,
      animations: { fromView.alpha = 0 }) { finished in
      transitionContext.completeTransition(finished)
    }
  }
}
