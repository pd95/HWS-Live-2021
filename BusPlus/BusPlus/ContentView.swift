//
//  ContentView.swift
//  BusPlus
//
//  Created by Philipp on 03.08.21.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct Bus: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
    let location: String
    let destination: String
    let passengers: Int
    let fuel: Int
    let image: URL

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct BusRow: View {

    let bus: Bus
    let isFavorite: Bool

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
                Text("\(bus.location) → **\(bus.destination)**")  // Added markdown styling to destination!
                    .accessibilityLabel("Traveling from \(bus.location) to \(bus.destination)")
                    .font(.caption)

                HStack(spacing: 5) {
                    Image(systemName: "person.2")
                        .foregroundColor(.cyan)
                    Text(String(bus.passengers))
                    Spacer()
                        .frame(width: 5)
                    Image(systemName: "fuelpump")
                        .foregroundStyle(LinearGradient(colors: [Color.green, Color.red], startPoint: .top, endPoint: .bottom))
                    Text(String(bus.fuel))
                }
                .symbolRenderingMode(.hierarchical)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(bus.passengers) passengers and \(bus.fuel) per cent fuel.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .opacity(isFavorite ? 1 : 0),
            alignment: .topTrailing
        )
    }
}

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

@MainActor
class UserData: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phoneNumber = ""
    @Published var ticketReference = ""

    var identfier: String {
        firstName + lastName + ticketReference
    }

    var isValid: Bool {
        !(firstName.isEmpty || lastName.isEmpty || ticketReference.isEmpty)
    }
}

struct TicketView: View {
    static let label = Label("Ticket", systemImage: "qrcode")
    static let tag = "Ticket"

    @EnvironmentObject var userData: UserData

    enum Field: Int, Hashable {
        case firstName, lastName, phoneNumber, ticketReference
    }

    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    TextField("First name", text: $userData.firstName)
                        .focused($focusedField, equals: .firstName)
                        .textContentType(.givenName)
                        .submitLabel(.next)

                    TextField("Last name", text: $userData.lastName)
                        .focused($focusedField, equals: .lastName)
                        .textContentType(.familyName)
                        .submitLabel(.next)

                    TextField("Phone number", text: $userData.phoneNumber)
                        .focused($focusedField, equals: .phoneNumber)
                        .textContentType(.telephoneNumber)
                        .submitLabel(.next)

                    TextField("Reference", text: $userData.ticketReference)
                        .focused($focusedField, equals: .ticketReference)
                        .keyboardType(.numberPad)
                        .submitLabel(.done)


                    qrCode
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 250, height: 250)
                        .padding()

                    Spacer()
                }
                .textFieldStyle(.roundedBorder)
                .padding()
                .onSubmit {
                    nextField()
                }
                .toolbar(content: {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Next") {
                            nextField()
                        }
                        .padding(.trailing)
                        Button("Done") {
                            focusedField = nil
                        }
                        .buttonStyle(.borderedProminent)
                    }
                })
                .task {
                    focusedField = .firstName
                }
                .navigationTitle("Personal ticket")
            }
        }
    }

    func nextField() {
        switch focusedField {
        case .firstName:
            focusedField = .lastName
        case .lastName:
            focusedField = .phoneNumber
        case .phoneNumber:
            focusedField = .ticketReference
        default:
            focusedField = nil
        }
    }


    // Generate a QR Code for user input
    @State private var context = CIContext()
    @State private var filter = CIFilter.qrCodeGenerator()

    var qrCode: Image {
        let id = userData.identfier
        let data = Data(id.utf8)
        filter.setValue(data, forKey: "inputMessage")
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return Image(uiImage: UIImage(cgImage: cgImage))
            }
        }
        return Image(systemName: "qrcode")
    }
}

struct ContentView: View {
    @StateObject private var userData = UserData()

    var body: some View {
        TabView {
            BusListView()
                .tabItem {
                    BusListView.label
                }

            TicketView()
                .tabItem {
                    TicketView.label
                }
                .badge(userData.isValid == false ? "!" : nil)
        }
        .environmentObject(userData)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
