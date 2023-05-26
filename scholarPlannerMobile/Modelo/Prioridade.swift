//
//  Prioridade.swift
//  scholarPlannerMobile
//
//  Created by Leonardo Ohasi on 25/05/23.
//

import Foundation
import SwiftUI

enum Priority: Int {
    case low = 0
    case medium = 1
    case high = 2

    var title: String {
        switch self {
        case .low:
            return "Prioridade baixa"
        case .medium:
            return "Prioridade média"
        case .high:
            return "Prioridade alta"
        }
    }

    var color: Color {
        switch self {
        case .low:
            return Color(#colorLiteral(red: 0.6274509804, green: 0.6274509804, blue: 1, alpha: 1))
        case .medium:
            return Color(#colorLiteral(red: 0, green: 0.8156862745, blue: 0, alpha: 1))
        case .high:
            return Color(#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1))
        }
    }
}

