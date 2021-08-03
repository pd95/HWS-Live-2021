//
//  ContentView.swift
//  MessageInbox
//
//  Created by Philipp on 02.08.21.
//

import SwiftUI

struct Message: Codable, Identifiable {
    let id: Int
    let user: String
    let text: String
}

func factors(for number: Int) async throws -> [Int] {
    var result = [Int]()

    for check in 1...number {
        if number.isMultiple(of: check) {
            result.append(check)

            // Artificial suspension point to allow Swift to schedule some other task
            await Task.suspend()

            // Check whether we should abort
            try Task.checkCancellation()
        }
    }

    return result
}

// Artificiall example using TaskGroup:
func printMessage() async {
    let string = await withTaskGroup(of: String.self) { group -> String in
        print("adding tasks to group")
        group.addTask(priority: .low) { "Hello" }
        group.addTask {
            try? await Task.sleep(seconds: Double.random(in: 0...3))
            return "From"
        }
        group.addTask {
            try? await Task.sleep(seconds: Double.random(in: 0...3))
            return "A"
        }
        group.addTask {
            try? await Task.sleep(seconds: Double.random(in: 0...3))
            return "Task"
        }
        group.addTask {
            try? await Task.sleep(seconds: Double.random(in: 0...3))
            return "Group"
        }

        //group.cancelAll()

        var collected = [String]()

        print("awaiting tasks...")
        for await value in group {
            print("  some value: \(value)")
            collected.append(value)
        }

        print("returning result")
        return collected.joined(separator: " ")
    }

    print(string)
}

struct ContentView: View {
    @State private var inbox = [Message]()
    @State private var sent = [Message]()

    @State private var selectedBox = "Inbox"
    let messageBoxes = ["Inbox", "Sent"]

    var body: some View {
        NavigationView {
            List(messages) { message in
                Text("\(message.user): ").bold() +
                Text(message.text)
            }
            .navigationTitle(selectedBox)
            .toolbar {
                Picker("Select a message box", selection: $selectedBox) {
                    ForEach(messageBoxes, id: \.self, content: Text.init)
                }
                .pickerStyle(.segmented)
            }
            .task {
//                // 1st approach: Simply call our async method using `try await`
//                do {
//                    inbox = try await fetchInbox()
//                } catch {
//                    print(error.localizedDescription)
//                }

//                // 2nd approach: Download messages in parallel using `async let`
//                do {
//                    let inboxURL = URL(string: "https://hws.dev/inbox.json")!
//                    let sentURL = URL(string: "https://hws.dev/sent.json")!
//
//                    async let inboxItems: [Message] = URLSession.shared.decode(from: inboxURL)
//                    async let sentItems: [Message] = URLSession.shared.decode(from: sentURL)
//
//                    // Await the result of the tasks
//                    inbox = try await inboxItems
//                    sent = try await sentItems
//                } catch {
//                    print(error.localizedDescription)
//                }

//                // 3rd approach: Use 2 independent tasks to download the messages
//                do {
//                    let inboxTask = Task{ () -> [Message] in
//                        let inboxURL = URL(string: "https://hws.dev/inbox.json")!
//                        return try await URLSession.shared.decode(from: inboxURL)
//                    }
//
//                    let sentTask = Task{ () -> [Message] in
//                        let sentURL = URL(string: "https://hws.dev/sent.json")!
//                        return try await URLSession.shared.decode(from: sentURL)
//                    }
//
//                    // Variant 1:
//                    // // Await the value of the tasks
//                    // inbox = try await inboxTask.value
//                    // sent = try await sentTask.value
//
//                    // Variant 2:
//                    // Await the result of the tasks
//                    let inboxResult = await inboxTask.result
//                    let sentResult = await sentTask.result
//
//                    // access the values of the results
//                    inbox = try inboxResult.get()
//                    sent = try sentResult.get()
//                } catch {
//                    print(error.localizedDescription)
//                }

//                // 4rd approach: Use independent tasks to download the messages and modify the UI state
//                //   => NO try catch necessary anymore.
//                Task {
//                    let inboxURL = URL(string: "https://hws.dev/inbox.json")!
//                    inbox = try await URLSession.shared.decode(from: inboxURL)
//                    // This code might not run
//                }
//
//                Task {
//                    let sentURL = URL(string: "https://hws.dev/sent.json")!
//                    sent = try await URLSession.shared.decode(from: sentURL)
//                    // This code might not run
//                }

//                // Priorities and priority escalation due to "await"
//                do {
//                    let inboxTask = Task(priority: .low) { () -> [Message] in
//                        print("inboxTask", Task.currentPriority)
//                        let inboxURL = URL(string: "https://hws.dev/inbox.json")!
//                        return try await URLSession.shared.decode(from: inboxURL)
//                    }
//
//                    let sentTask = Task{ () -> [Message] in
//                        print("sentTask", Task.currentPriority)
//                        let sentURL = URL(string: "https://hws.dev/sent.json")!
//                        return try await URLSession.shared.decode(from: sentURL)
//                    }
//
//                    // Await the value of the tasks
//                    inbox = try await inboxTask.value
//                    sent = try await sentTask.value
//                } catch {
//                    print(error.localizedDescription)
//                }

                // Task cancellation and TaskGroup
                do {
                    // Submit our artificial example task (using an independent Task)
                    Task(priority: .low, operation: {
                        await printMessage()
                    })

                    // Collecting multiple pages of the inbox messages using a TaskGroup
                    inbox = try await withThrowingTaskGroup(of: [Message].self, body: { group -> [Message] in
                        for i in 1...3 {
                            group.addTask {
                                let inboxURL = URL(string: "https://hws.dev/inbox-\(i).json")!
                                return try await URLSession.shared.decode(from: inboxURL)
                            }
                        }
                        //group.cancelAll()

                        // The parts come back in a random order...
                        let allMessages = try await group.reduce(into: [Message](), { $0 += $1 })

                        // ... and need sorting!
                        return allMessages.sorted(by: { $0.id < $1.id })
                    })

                    let sentTask = Task { () -> [Message] in
                        // artificially sleep here
                        try await Task.sleep(seconds: 1)

                        // Check whether we have been canceled before doing actual work
                        // throws a Task.CancellationError
                        try Task.checkCancellation()

                        let sentURL = URL(string: "https://hws.dev/sent.json")!
                        return try await URLSession.shared.decode(from: sentURL)
                    }

                    // Cancelling the task to abort its fetch
                    //sentTask.cancel()

                    sent = try await sentTask.value
                } catch {
                    print(error.localizedDescription)
                }

            }
        }
    }

    var messages: [Message] {
        if selectedBox == "Inbox" {
            return inbox
        } else {
            return sent
        }
    }

    // New style async method
    func fetchInbox() async throws -> [Message] {
        let inboxURL = URL(string: "https://hws.dev/inbox.json")!
        return try await URLSession.shared.decode(from: inboxURL)
    }


    /*
    // Old style method using a completion handler
    func fetchInbox(completion: @escaping (Result<[Message], Error>) -> Void) {
        let inboxURL = URL(string: "https://hws.dev/inbox.json")!

        URLSession.shared.dataTask(with: inboxURL) { data, response, error in
            if let data = data {
                if let messages = try? JSONDecoder().decode([Message].self, from: data) {
                    completion(.success(messages))
                    return
                }
            } else if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success([]))
        }.resume()
    }

    // Async wrapper to use old
    func fetchInbox() async throws -> [Message] {
        try await withCheckedThrowingContinuation({ continuation in
            fetchInbox { result in
                switch result {
                case .success(let messages):
                    continuation.resume(returning: messages)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
                // Alternatively use the Result<...>
                //continuation.resume(with: result)
            }
        })
    }
*/
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
