//
//  ContentView.swift
//  Actor
//
//  Created by Philipp on 03.08.21.
//

import SwiftUI
import CryptoKit

// Artificial example:
actor SimpleUser {
    let maximumScore = 100
    var score = 10

    func printScore() {
        print("My score is \(score)")
    }

    func copyScore(from other: SimpleUser) async {
        score = await other.score   // need to await the value

        print(other.maximumScore)   // no need to await when accessing a constant property
    }
}


// Real world example: Caching data from an URLSession
actor URLCache {
    private var cache = [URL: Data]()

    func data(for url: URL) async throws -> Data {
        if let cached = cache[url] {
            return cached
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        cache[url] = data
        return data
    }
}

// CS class example for concurrency: bank accounts and money transfers
actor BankAccount {
    var balance: Decimal

    init(initialBalance: Decimal) {
        balance = initialBalance
    }

    func deposit(amount: Decimal) {
        balance = balance + amount
    }

    func transfer(amount: Decimal, to other: BankAccount) async {
        guard balance >= amount else { return }
        balance = balance - amount
        await other.deposit(amount: amount)
    }
}


// Simple solution: Players are String
actor SimpleTeam {

    var players: Set<String>

    init(name: String, players: Set<String>) {
        self.players = players
    }

    func transfer(player: String, to team: SimpleTeam) async {
        guard players.contains(player) else { return }
        players.remove(player)
        await team.receive(player: player)
    }

    func receive(player: String) async {
        players.insert(player)
    }
}


// More complex solition: Team and Player are actors and player is a `Set`
actor BasketballTeam {
    var players: Set<Player>

    init(name: String, players: Set<Player>) {
        self.players = players
    }

    func transfer(player: Player, to team: BasketballTeam) async {
        guard players.contains(player) else { return }
        players.remove(player)
        await team.receive(player: player)
    }

    func receive(player: Player) async {
        players.insert(player)
    }
}

actor Player: Hashable {
    let id: Int
    var name: String
    var salary: Decimal

    init(id: Int, name: String, salary: Decimal) {
        self.id = id
        self.name = name
        self.salary = salary
    }

    func offerRaise(amount: Decimal) {
        guard amount > 0 else {
            print("That's it, I quit!")
            return
        }

        salary += amount
    }

    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    nonisolated var hashValue: Int {
        id
    }
}

// MARK: - `isolated` keyword on actor type parameter
// Showing `isolated` keyword for an actor parameter
// This still ensures that the "actor related magic" happens before running
// the functions code
actor DataStore {
    var username = "Anonymous"
    var friends = [String]()
    var highScores = [Int]()
    var favorites = Set<Int>()
}

func debugLog(dataStore: isolated DataStore) {
    print("Username: \(dataStore.username)")
    print("Friends: \(dataStore.friends)")
    print("High scores: \(dataStore.highScores)")
    print("Favorites: \(dataStore.favorites.count)")
}


// MARK: - `nonisolated` keyword function decorator
// Using the `nonisolated` keyword to allow calculations based on read-only properties
// and adding Codable conformance for the actor (read-only properties again!)
actor User: Codable {
    enum CodingKeys: CodingKey {
        case username, password
    }

    let username: String
    let password: String
    var isOnline = false

    init(username: String, password: String, isOnline: Bool = false) {
        self.username = username
        self.password = password
        self.isOnline = isOnline
    }

    nonisolated func passwordHash() -> String {
        let passwordData = Data(password.utf8)
        let hash = SHA256.hash(data: passwordData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
    }
}


// MARK: - Global actor `MainActor`
// This makes sure our view model is only executed on the main actor
@MainActor
class ViewModel: ObservableObject {
    @Published var name = "Bob"
    @Published var isAuthenticated = false
}

struct ContentView: View {
    // Adding this property to the view will make the View's code be executed only on
    // the main thread. Therefore any `Task` which is spun-off this code will also be
    // bound to the `MainActor`, resulting in sequential execution!
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Button("Do some heavy work!", action: doWork)
        }
        //.task(doWork)
    }

    func doWork() {
        // Tasks run from a view (which is bound to the MainActor due to its properties
        // are automatically "inheriting" the views actor. You have to detach the task!
        // FIXME: on M1 macs (on Big Sur) the tasks still run sequentially in the Simulator
        let symbols = ["🟢","🔴","⚫️"]
        for j in 0..<symbols.count {
            Task.detached {
                for i in 1...100_000 {
                    print("task \(j+1) \(symbols[j]): \(i)")
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
