//
//  TicketView.swift
//  TicketView
//
//  Created by Philipp on 05.08.21.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

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


struct TicketView_Previews: PreviewProvider {
    static var previews: some View {
        TicketView()
            .environmentObject(UserData())
    }
}
