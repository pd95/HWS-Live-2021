//
//  ContentView.swift
//  Petitions
//
//  Created by Philipp on 02.08.21.
//

import SwiftUI

struct Petition: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    let signatureThreshold: Int
    let signatureCount: Int
    let created: Date
    let deadline: Date
}

struct PetitionView: View {
    let petition: Petition

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(petition.title)
                    .font(.title)
                    .padding(.bottom)

                HStack {
                    Text("Signatures: ")
                    Text("\(petition.signatureCount)/\(petition.signatureThreshold)")
                    Text("\(NSNumber(value: Double(petition.signatureCount) / Double(petition.signatureThreshold)), formatter: percentFormatter)")
                }
                .font(.headline)
                .padding(.vertical)

                Text("Created: ") + Text(petition.created, style: .date)
                Text("Deadline: ") + Text(petition.deadline, style: .date)

                Text(petition.body)
            }
            .padding()
        }
        .navigationTitle("Petition details")
    }

    var percentFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }
}


struct ContentView: View {

    @State private var petitions = [Petition]()

    var body: some View {
        NavigationView {
            List(petitions) { petition in
                NavigationLink(destination: PetitionView(petition: petition)) {
                    VStack(alignment: .leading) {
                        Text(petition.title)
                            .font(.headline)
                            .minimumScaleFactor(0.99)

                        HStack {
                            Text(petition.deadline, style: .relative)
                            Spacer()
                            Text("\(petition.signatureCount)/\(petition.signatureThreshold)")
                        }
                        if petition.signatureCount < petition.signatureThreshold {
                            ProgressView(value: Double(petition.signatureCount),
                                         total: Double(petition.signatureThreshold))
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Petitions")
            .task {
                do {
                    let url = URL(string: "https://hws.dev/petitions.json")!
                    let decodedData: [Petition] = try await URLSession.shared.decode(from: url, dateDecodingStrategy: .secondsSince1970)
                    petitions = decodedData
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
