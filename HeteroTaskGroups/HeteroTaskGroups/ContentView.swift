//
//  ContentView.swift
//  HeteroTaskGroups
//
//  Created by Philipp on 03.08.21.
//

import SwiftUI


struct NewsStory: Decodable, Identifiable {
    let id: Int
    let title: String
    let strap: String
}

struct Score: Decodable {
    let name: String
    let score: Int
}

// The struct we want to have at the end:
struct ViewModel {
    let stories: [NewsStory]
    let scores: [Score]
}

// The enum we use to make sure our tasks can return the same type
enum FetchResult {
    case newsStories([NewsStory])
    case score([Score])
}

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .task(loadData)
    }

    /// Fetching a heterogenious set of data: NewsStories and Scores unsing TaskGroups
    func loadData() async {
        let viewModel = await withThrowingTaskGroup(of: FetchResult.self, body: { group -> ViewModel in

            group.addTask {
                let url = URL(string: "https://hws.dev/headlines.json")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode([NewsStory].self, from: data)
                return .newsStories(result)
            }

            group.addTask {
                let url = URL(string: "https://hws.dev/scores.json")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode([Score].self, from: data)
                return .score(result)
            }

            var newsStories = [NewsStory]()
            var scores = [Score]()

            do {
                for try await value in group {
                    switch value {
                    case .newsStories(let fetchedStories):
                        newsStories = fetchedStories
                    case .score(let fetchedScores):
                        scores = fetchedScores
                    }
                }
            } catch {
                print("Fetch at least partially failed: \(error.localizedDescription)")
            }

            return ViewModel(stories: newsStories, scores: scores)
        })

        print(viewModel.stories)
        print(viewModel.scores)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
