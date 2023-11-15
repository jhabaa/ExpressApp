//
//  AnimExtensions.swift
//  ExpressAppTemp
//
//  Created by Jean Hubert ABA'A on 15/03/2022.
//

import Foundation
import SwiftUI

extension Animation{
    static func logoAnimation() -> Animation{
        Animation.spring(dampingFraction: 0.5, blendDuration: 5)
            .speed(0.2)
    }
    static func textAppear() -> Animation{
        Animation.spring(dampingFraction:0.4)
            .speed(0.1)
        
    }
    static func infiniteEase()->Animation{
        Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true).speed(0.5)
    }
    static func extendMenu() -> Animation{
        Animation.spring(dampingFraction: 0.5, blendDuration: 2.5)
            .speed(2)
    }
    static func menuBar() -> Animation{
        Animation.spring(dampingFraction: 0.5, blendDuration: 5)
            .speed(4).delay(5.0)
    }
    
    static func infiniteRotate() -> Animation{
        Animation.linear(duration: 0.2)
            .delay(4)
    }
    static func pulse() -> Animation{
        Animation.spring(response:1, blendDuration: 0.4).repeatForever(autoreverses: true)
            .speed(0.4)
    }
    static func up() -> Animation{
        Animation.linear(duration: 0.1)
            
    }
    static func loading() -> Animation{
        Animation.spring().repeatForever()
    }
    static func notificationBubble() -> Animation{
        Animation.spring(response: 0.1, dampingFraction: 0.9, blendDuration: 0.2)
            .speed(0.4).delay(0.1)
    }
    
    
    
    static func priceJump() -> Animation{
        @Binding var off:Bool
        return Animation.spring(response: 1, dampingFraction: 0.2, blendDuration: 3)
            .speed(3)
    }
    static func imageAnimation() -> Animation{
        Animation.easeInOut(duration: 10).repeatForever()
    }
    
    static func SuppressAnimation() -> Animation{
        Animation.spring(response: 0.2, dampingFraction: 1.2, blendDuration: 0.4).repeatForever()
    }
}

extension AnyTransition{
    static var transition1: AnyTransition{
        .asymmetric(
            insertion: .scale(scale: 0.9, anchor: UnitPoint.center).combined(with: .opacity),
                    removal: .scale(scale: 1, anchor: UnitPoint.center).combined(with: .opacity)
                )
    }
    
    static var NewUserPage:AnyTransition{
        .asymmetric(insertion: AnyTransition.move(edge: .top), removal: .move(edge: .bottom).combined(with: scale(scale: 0.2, anchor: UnitPoint.bottom)))
    }
}

let moveUp = CGAffineTransform.init(translationX: 0, y: -200)
let stand = CGAffineTransform.init(translationX: 0, y: 0)
