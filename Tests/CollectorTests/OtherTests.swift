import Foundation
import Testing
import AsyncAlgorithms

struct ExecuteAfterTimeout {

    private let task: Task<Void, Never>

    init(of timeout: Duration, action: @escaping @Sendable () throws -> Void) {
        task = Task {
            do {
                try await Task.sleep(for: timeout)
                try action()
            }
            catch {}
        }
    }

    func cancel() {
        task.cancel()
    }
}

@Test func simpleQueueWithAsyncChannel() async throws {
    let channel = AsyncChannel<String>()

    let _ = ExecuteAfterTimeout(of: .milliseconds(5)) {
        channel.finish()
    }

    /// Sends an element to an **awaiting** iteration.
    async let _ = Task {
        await channel.send("hello")
    }

    var values: [String] = []
    for await value in channel {
        values.append(value)
    }

    #expect(values == ["hello"])
}
