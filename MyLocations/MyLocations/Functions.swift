//
//  Functions.swift
//  MyLocations
//
//  Created by Борис on 03.01.2021.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: {
    run()
  })
}
