//
//  ContentView.swift
//  DeeplinkTesting
//
//  Created by Danila Gusev on 14.04.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var numberOfCalls: Int = .zero
    @State private var lastUrl: String?
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .center, spacing: .zero) {
                Text("Calls count:")
                Text("\(numberOfCalls)")
                    .accessibilityIdentifier(TestIdentifier.ContentView.count)
            }

            Divider()
            VStack(alignment: .center, spacing: .zero) {
                Text("Last url:")
                Text("\(lastUrl ?? "None")")
                    .accessibilityIdentifier(TestIdentifier.ContentView.link)
            }
            .foregroundStyle(lastUrl != nil ? .black : .gray)
        }
        .padding()
        .multilineTextAlignment(.center)
        .onOpenURL(perform: handleURL)
    }
}

private extension ContentView {
    func handleURL(_ url: URL) {
        numberOfCalls += 1
        lastUrl = url.absoluteString
    }
}

#Preview {
    ContentView()
}
