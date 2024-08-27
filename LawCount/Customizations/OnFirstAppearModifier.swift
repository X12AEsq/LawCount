//
//  OnFirstAppearModifier.swift
//  LawCount
//
//  Created by Morris Albers on 8/26/24.
//

import Foundation
import SwiftUI

public struct OnFirstAppearModifier: ViewModifier {

    private let onFirstAppearAction: () -> ()
    @State private var hasAppeared = false
    
    public init(_ onFirstAppearAction: @escaping () -> ()) {
        self.onFirstAppearAction = onFirstAppearAction
    }
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                guard !hasAppeared else { return }
                hasAppeared = true
                onFirstAppearAction()
            }
    }
}

extension View {
    func onFirstAppear(_ onFirstAppearAction: @escaping () -> () ) -> some View {
        return modifier(OnFirstAppearModifier(onFirstAppearAction))
    }
}

/*
 struct ContentView: View {
     var body: some View {
         NavigationStack {
             VStack {
                 Text("First View!!!")
                 Image(systemName: "globe")
                     .imageScale(.large)
                     .foregroundStyle(.tint)
                     .padding()
                 
                 NavigationLink("Next View") {
                     View2()
                 }.buttonStyle(.borderedProminent)
             }
             .padding()
             .onFirstAppear {
                 print("⭐️ On First Appear ! \(Date())")
             }
             .onAppear {
                 print("Run on Appear!!! \(Date())")
             }
             .onDisappear {
                 print("Run on Disappear!! \(Date())")
             }
             .task({
                 print("📀 Task print!")
             })
         }
     }
 }

 struct View2: View {
     var body: some View {
         NavigationStack {
             VStack {
                 Text("This is View 2")
                     .padding()
                 Image(systemName: "star")
                     .imageScale(.large)
                     .foregroundStyle(.tint)
             }
             .padding()
         }
     }
 }
 */
