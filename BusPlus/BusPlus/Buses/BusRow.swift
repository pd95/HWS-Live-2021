//
//  BusRow.swift
//  BusRow
//
//  Created by Philipp on 05.08.21.
//

import SwiftUI

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



struct BusRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BusRow(bus: .example, isFavorite: false)
            BusRow(bus: .example, isFavorite: true)
        }
        .previewLayout(.fixed(width: 350, height: 150))
    }
}
