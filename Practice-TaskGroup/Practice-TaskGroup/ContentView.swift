//
//  ContentView.swift
//  Practice-TaskGroup
//
//  Created by Philipp on 03.08.21.
//

import SwiftUI

struct Message: Codable, Identifiable {
    let id: Int
    let from: String
    let message: String
}

enum TaskReturn {
    case string(String)
    case int([Int])
    case message([Message])
}

struct User {
    let username: String
    let messages: [Message]
    let favorites: Set<Int>
}

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
            .task(loadData)
    }

    func loadData() async {
        let user = await withThrowingTaskGroup(of: TaskReturn.self, body: { group -> User in
            group.addTask {
                let url = URL(string: "https://hws.dev/username.json")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = String(data: data, encoding: .utf8)!
                return .string(result)
            }
            group.addTask {
                let url = URL(string: "https://hws.dev/user-messages.json")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode([Message].self, from: data)
                return .message(result)
            }
            group.addTask {
                let url = URL(string: "https://hws.dev/user-favorites.json")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode([Int].self, from: data)
                return .int(result)
            }

            var username = "No name"
            var favoriteIDs = [Int]()
            var messages = [Message]()

            do {
                for try await value in group {
                    switch value {
                    case .string(let name):
                        username = name
                    case .int(let numbers):
                        favoriteIDs = numbers
                    case .message(let fetchedMessage):
                        messages = fetchedMessage
                    }
                }
            } catch {
                print("Some error occured", error)
            }

            return User(username: username, messages: messages, favorites: Set(favoriteIDs))
        })

        print("User \(user.username) has \(user.messages.count) messages and \(user.favorites.count) favorites.")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
