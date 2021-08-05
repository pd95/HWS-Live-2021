# Hacking with Swift Live 2021

My Xcode projects and sources created during [Hacking With Swift Live](http://hackingwithswift.com/live) online-workshops hosted by [@twostraws](https://github.com/twostraws).

## Day 1

- [Various Swift 5.5 features and additions](SwiftFeatures): Check out the code [ContentView.swift](SwiftFeatures/SwiftFeatures/ContentView.swift)

- [Message Inbox](Concurrency-Message-Inbox): Learning about the new basic concurrency features: `async` and `await` keywords, 
  SwiftUI `.task` modifier (as alternative to `.onAppear`),  `async let` assignment and `Task` struct to run/submit parallel tasks

- [Practice Petitions](Practice-Petitions): Writing a small app showing "petitions" fetched and decoded using the new concurrency approach

- [Practice Chat Messages](Practice-ChatMessages): Writing an app downloading 3 independent JSON data files and displaying them using SwiftUI

## Day 2

- [Message Inbox](Concurrency-Message-Inbox): Learning more about the concurrency features: Task `suspend`, cancellation, `sleep`, `TaskGroup`. Read the code in [ContentView.swift](Concurrency-Message-Inbox/MessageInbox/ContentView.swift)

- [Practice News Stories](Practice-NewsStories): Writing a small app showing news stories fetched from 5 JSON feeds, concatenating and sorting for display.

- [Heterogenous TaskGroups](HeteroTaskGroups): How to handle tasks within a `TaskGroup` returing different types? Wrap the result in an `enum`! Read the code in [ContentView.swift](HeteroTaskGroups/HeteroTaskGroups/ContentView.swift)

- [Practice TaskGroup](Practice-TaskGroup): Writing a asynchonous `loadData` method fetching data from different locations and of different types, combining the result before updating the views model. Read the code in [ContentView.swift](Practice-TaskGroup/Practice-TaskGroup/ContentView.swift)!

- [Actor](Actor): What is an actor and its purpose? Simple examples in [ContentView.swift](Actor/Actor/ContentView.swift): `URLCache`, `BankAccount`, `BasketballTeam` and `Player`. Handling `Hashable` and `Codable` for actors, when to use `nonisolated` and `isolated` keyword and how global actors, the `MainActor` fit into the picture.  

  **Bonus:** Using `Task.detached` to run code parallely not bound to the same actor which the View might inherit from its properties!

- [Bus+](BusPlus): new features in SwiftUI so far `AsyncImage`, `.task` modifier (to be continued on day 3!)

## Day 3

- [AsyncSequence](https://github.com/pd95/HWS-Live-2021-AsyncSequence/): This session was an introduction to `AsyncSequence` hosted by [Daniel H Steinberg](https://dimsumthinking.com).
  First reminder about `Sequence` and `Iterator` protocol and conformance, then introducing asynchronicity by using notifications (and the new `Notification` sequence which conforms to `AsyncSequence`), implementing own data model using `AsyncSequence` and `AsyncIterator`, finally using `AsyncStream`.

- [Bus+](BusPlus): illustrating more new features of SwiftUI
  - `refreshable` to reload busses list with a "pull to refresh" gesture
  - `searchable` to allow searching/filtering the list of busses
  - Adding `swipeActions` for "Add favorite" button
  - tinting list row separators and using a few new colors `indigo`, `mint` and `cyan`
  - using `foregroundStyle` to add a gradient drawing to a SF symbol
  - using `symbolRenderingMode` to draw SF symbols hierarchically
  - using Markdown styling for `Text` rendering
  - using `ultraThinMaterial` to have a blured background when a bus has been selected
  - using `focused` modifier, `submitLabel` and `onSubmit` to implement a User input form with automatic input focussing.
  - adding "Next" and "Done" buttons to keyboard toolbar (using `ToolbarItemGroup(placement: .keyboard)`)
  - illustrating `ObservableObject` using `@MainActor` to validate some user data
  - adding a `badge` modifier to a `tabItem`to highlight missing user input
  - **Bonus**: generating a QR code from user provided data (using CoreImage `CIFilter`)
  - **Bonus**: using `Mirror` to introspect `Bus` type for improved search completion