//
//  ContentView.swift
//  Practice-NewsStories
//
//  Created by Philipp on 03.08.21.
//

import SwiftUI

struct NewsStory: Codable, Identifiable {
    let id: Int
    let title: String
    let strap: String
    let url: URL
    let mainImage: URL
    let publishedDate: Date
}

struct StoryRow: View {
    let story: NewsStory

    var body: some View {
        // Using the new AsyncImage to fetch image
        AsyncImage(url: story.mainImage) { phase in
            if let image = phase.image {
                image
                    .resizable()
            } else if phase.error != nil {
                Color.red // Indicates an error.
            } else {
                // Fill "empty space" with clear color and progress spinner
                Color.clear
                    .overlay(ProgressView())
            }
        }
        .aspectRatio(16/9, contentMode: .fill)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 70)
        .overlay(
            VStack(alignment: .leading) {
                Text(story.title)
                    .font(.headline)
                Text(story.strap)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(.thinMaterial),
            alignment: .bottom
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ContentView: View {
    @State private var stories = [NewsStory]()

    var body: some View {
        NavigationView {
            List(stories) { story in
                StoryRow(story: story)
            }
            .listStyle(.plain)
            .task {
                await loadStories()
            }
            .navigationTitle("Latest News")
        }
    }

    func loadStories() async {
        do {
            try await withThrowingTaskGroup(of: [NewsStory].self) { group -> Void in
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601

                for i in 1...5 {
                    group.addTask {
                        let url = URL(string: "https://hws.dev/news-\(i).json")!
                        let (data, _) = try await URLSession.shared.data(from: url)
                        try Task.checkCancellation()
                        return try decoder.decode([NewsStory].self, from: data)
                    }
                }

                for try await result in group {
                    stories.append(contentsOf: result)
                }

                stories.sort(by: { $0.id > $1.id })
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
