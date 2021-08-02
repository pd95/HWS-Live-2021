//
//  ContentView.swift
//  SwiftFeatures
//
//  Created by Philipp on 02.08.21.
//

import SwiftUI

struct User: Identifiable {
    let id = UUID()
    var name: String
    var isContacted = false
}


// -------------------------------------
// Property wrapper for an argument
@propertyWrapper struct Clamped<T: Comparable> {
    let wrappedValue: T

    init(wrappedValue: T, range: ClosedRange<T>) {
        self.wrappedValue = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}

func setScore(@Clamped(range: 0...100) to score: Int) {
    print("Setting score to \(score)")
}

func testWrapper() {
    setScore(to: 50)
    setScore(to: -50)
    setScore(to: 500)
}

// -------------------------------------
// Synthesizing Codable for more enums
enum Vehicle: Codable {
    case bicycle(electric: Bool)
    case motorbike
    case car(seats: Int)
    case truck(wheels: Int)
}


// -------------------------------------
// A function which does a lot of work
func fibonacci(of number: Int) -> Int {
    var first = 0
    var second = 1

    for _ in 0..<number {
        let previous = first
        first = second
        second = previous + first
    }

    return first
}

// Lazy initialization of `result`
func printFibonacci( of number: Int, allowsAbsolute: Bool = false) {
     lazy var result = fibonacci(of: abs(number))

    if number < 0 {
        if allowsAbsolute {
            print("The result for \(abs(number)) is \(result)")
        } else {
            print("That's not a valid numnber in the sequence.")
        }
    } else {
        print("The result for \(number) is \(result).")
    }
}

func test() {
    let traffic: [Vehicle] = [
        .bicycle(electric: false),
        .bicycle(electric: false),
        .car(seats: 4),
        .bicycle(electric: true),
        .motorbike,
        .truck(wheels: 8)
    ]

    do {
        let jsonData = try JSONEncoder().encode(traffic)
        let jsonString = String(decoding: jsonData, as: UTF8.self)
        print(jsonString)
    } catch {
        print("error", error)
    }
}

struct ContentView: View {
    @State private var users = [
        User(name: "Taylor"),
        User(name: "Justin"),
        User(name: "Adele")
    ]

    var body: some View {
        // Pass a binding to SwiftUI
//        List($users) { $user in
//            HStack {
//                Text(user.name)
//                Spacer()
//                Toggle("User has been contected", isOn: $user.isContacted)
//                    .labelsHidden()
//            }
//        }
        Text("Hello World")
            .onAppear {
                testWrapper()
                test()
                printFibonacci(of: 23)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
