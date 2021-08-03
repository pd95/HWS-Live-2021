//
//  ContentView.swift
//  BusPlus
//
//  Created by Philipp on 03.08.21.
//

import SwiftUI

struct Bus: Decodable, Identifiable {
    let id: Int
    let name: String
    let location: String
    let destination: String
    let passengers: Int
    let fuel: Int
    let image: URL
}

struct BusRow: View {
    let bus: Bus

    var body: some View {
        HStack {
            AsyncImage(url: bus.image) { image in
                image
                    .resizable()
            } placeholder: {
                Image(systemName: "bus")
                    .resizable()
                    .padding()
            }
            .frame(width: 64, height: 64)
            .cornerRadius(5)

            VStack(alignment: .leading) {
                Text(bus.name)
                    .font(.headline)
                Text("\(bus.location) → \(bus.destination)")
                    .accessibilityLabel("Traveling from \(bus.location) to \(bus.destination)")
                    .font(.caption)

                HStack(spacing: 5) {
                    Image(systemName: "person.2")
                    Text(String(bus.passengers))
                    Spacer()
                        .frame(width: 5)
                    Image(systemName: "fuelpump")
                    Text(String(bus.fuel))
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(bus.passengers) passengers and \(bus.fuel) per cent fuel.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


struct ContentView: View {
    @State private var buses = [Bus]()

    var body: some View {
        NavigationView {
            List(buses) { bus in
                BusRow(bus: bus)
            }
            .navigationTitle("Bus+")
            .task {
                if buses.isEmpty {
                    await fetchData()
                }
            }
        }
    }

    func fetchData() async {
        let url = URL(string: "https://hws.dev/bus-timetable")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            buses = try JSONDecoder().decode([Bus].self, from: data)
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
