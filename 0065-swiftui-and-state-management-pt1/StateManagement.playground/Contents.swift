import SwiftUI

struct ContentView: View {
    @ObservedObject var state: AppState

    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: CounterView(state: self.state)) {
                    Text("Counter demo")
                }
                NavigationLink(destination: EmptyView()) {
                    Text("Favorite primes")
                }
            }
            .navigationBarTitle("State management")
        }
    }
}

private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}

//BindableObject

import Combine

class AppState: ObservableObject, Codable {
    static private let userDefaultsKey: String = "AppState"

    @Published var count: Int = 0 {
        didSet {
            save()
        }
    }

    private enum CodingKeys: String, CodingKey {
        case count
    }

    init() {
        if
            let data: Data = UserDefaults.standard.data(forKey: Self.userDefaultsKey),
            let state: Self = try? JSONDecoder().decode(Self.self, from: data)
        {
            self.count = state.count
        }
    }

    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        count = try values.decode(Int.self, forKey: .count)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(count, forKey: .count)
    }

    private func save() {
        if let encoded: Data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: Self.userDefaultsKey)
        }
    }
}

struct CounterView: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack {
            HStack {
                Button(action: { self.state.count -= 1 }) {
                    Text("-")
                }
                Text("\(self.state.count)")
                Button(action: { self.state.count += 1 }) {
                    Text("+")
                }
            }
            Button(action: {}) {
                Text("Is this prime?")
            }
            Button(action: {}) {
                Text("What is the \(ordinal(self.state.count)) prime?")
            }
        }
        .font(.title)
        .navigationBarTitle("Counter demo")
    }
}


import PlaygroundSupport

PlaygroundPage.current.liveView = UIHostingController(
    rootView: ContentView(state: AppState())
    //  rootView: CounterView()
)
