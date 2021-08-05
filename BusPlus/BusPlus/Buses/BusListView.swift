//
//  BusListView.swift
//  BusListView
//
//  Created by Philipp on 05.08.21.
//

import SwiftUI

struct BusListView: View {

    static let tag = "BusList"
    static let label = Label("Buses", systemImage: "bus")

    @State private var buses = [Bus]()
    @State private var selectedBus: Bus?
    @State private var search = ""

    @State private var favorites = Set<Bus>()

    var body: some View {
        NavigationView {
            ZStack {
                List(filteredBuses) { bus in
                    let isFavorite = favorites.contains(bus)

                    BusRow(bus: bus, isFavorite: isFavorite)
                        .swipeActions {
                            Button{
                                toggle(favorite: bus)
                            } label: {
                                if isFavorite {
                                    Label("Remove Favorite", systemImage: "star.slash")
                                } else {
                                    Label("Add Favorite", systemImage: "star")
                                }
                            }
                            .tint(Color.yellow)
                        }
                        .listRowSeparatorTint(.indigo)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                self.selectedBus = bus
                            }
                        }
                }
                .refreshable(action: fetchData)
                .searchable(text: $search.animation()) {
                    if !search.isEmpty {
                        withAnimation {
                            ForEach(searchSuggestion) { suggestion in
                                Text("Did you mean \(suggestion.value) (\(suggestion.label))?")
                                    .minimumScaleFactor(0.99)
                                    .searchCompletion(suggestion.value)
                            }
                        }
                    }
                }
                .navigationTitle("Bus+")
                .task {
                    if buses.isEmpty {
                        await fetchData()
                    }
                }
                if let selectedBus = selectedBus {
                    VStack {
                        AsyncImage(url: selectedBus.image) { image in
                            image
                                .resizable()
                                .cornerRadius(10)
                        } placeholder: {
                            Image(systemName: "bus")
                                .resizable()
                                .padding()
                        }
                        .frame(width: 275, height: 275)
                        .shadow(radius: 20)
                        //.padding(20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .transition(.scale)
                    .onTapGesture {
                        withAnimation {
                            self.selectedBus = nil
                        }
                    }
                }
            }
        }
    }

    func toggle(favorite bus: Bus) {
        if favorites.contains(bus) {
            favorites.remove(bus)
        } else {
            favorites.insert(bus)
        }
    }

    var filteredBuses: [Bus] {
        guard !search.isEmpty else {
            return buses
        }
        return buses.filter({ bus in

            /*
            // Bonus: Use "Mirror" to inspect object metadata and check it
            let busMirror = Mirror(reflecting: bus)
            for child in busMirror.children {
                if let value = child.value as? String {
                    if value.localizedStandardContains(search) {
                        print("\(child.label ?? "-") = \(value) matches \(search)")
                        return true
                    }
                }
            }
            return false
            */

            [bus.name, bus.location, bus.destination].first(where: {
                $0.localizedStandardContains(search)
            }) != nil
        })
    }

    //------------------ "intelligent" search suggestions
    struct SearchSuggestion: Identifiable, Hashable, CustomStringConvertible {
        let id = UUID()

        let label: String
        let value: String

        var description: String {
            "\(label): \(value)"
        }
    }

    var searchSuggestion: [SearchSuggestion] {
        guard !search.isEmpty else {
            return []
        }

        var allSuggestions = [String:[String]]()
        buses.forEach({ bus in

            // Bonus: Use "Mirror" to inspect object metadata and check it
            let busMirror = Mirror(reflecting: bus)
            for child in busMirror.children {
                if let label = child.label,
                   let value = child.value as? String
                {
                    if value.localizedStandardContains(search) {
                        print("\(label) = \(value) matches \(search)")

                        if let properties = allSuggestions[value] {
                            if properties.contains(label) == false {
                                allSuggestions[value, default: []].append(label)
                            }
                        } else {
                            allSuggestions[value] = [label]
                        }
                    }
                }
            }
        })

        return allSuggestions.map {
            SearchSuggestion(label: $0.value.sorted().joined(separator: ", "), value: $0.key)
        }
        .sorted {
            if $0.label < $1.label {
                return $0.value < $1.value
            }
            else {
                return $0.value < $1.value
            }
        }
    }

    func fetchData() async {
        let url = URL(string: "https://hws.dev/bus-timetable")!
        do {
            await Task.sleep(500_000_000)  // artificial sleep to allow seeing spinner
            let (data, _) = try await URLSession.shared.data(from: url)
            buses = try JSONDecoder().decode([Bus].self, from: data)
        } catch {
            print(error.localizedDescription)
        }
    }
}


struct BusListView_Previews: PreviewProvider {
    static var previews: some View {
        BusListView()
    }
}
