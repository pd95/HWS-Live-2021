//
//  ContentView.swift
//  ChatMessages
//
//  Created by Philipp on 02.08.21.
//

import SwiftUI

struct User: Codable, Identifiable {
    let id: UUID
    let name: String
    let age: Int
}

struct Message: Codable, Identifiable {
    let id: Int
    let from: String
    let message: String
}

struct ContentView: View {

    @State private var user: User?
    @State private var messages = [Message]()
    @State private var favoriteMessageID = Set<Int>()

    var title: String {
        guard let user = user else {
            return "Loading..."
        }
        return "\(user.name), \(user.age)"
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(messages) { message in
                    Section(header: HStack {
                        Text("\(message.from): ").bold()
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .opacity(favoriteMessageID.contains(message.id) ? 1 : 0)
                    }) {
                        Text(message.message)
                    }
                }
            }
            .navigationBarTitle(title)
            .task {
                let userURL = URL(string: "https://hws.dev/user-24601.json")!
                let messageURL = URL(string: "https://hws.dev/user-messages.json")!
                let favoritesURL = URL(string: "https://hws.dev/user-favorites.json")!
                do {
                    async let user: User = URLSession.shared.decode(from: userURL)
                    async let messages: [Message] = URLSession.shared.decode(from: messageURL)
                    async let favorites: [Int] = URLSession.shared.decode(from: favoritesURL)

                    self.messages = try await messages
                    self.user = try await user
                    self.favoriteMessageID = Set(try await favorites)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
