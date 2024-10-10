import Foundation
import Testing
import AsyncAlgorithms

@Test func simpleQueueWithAsyncChannel() async throws {
    let channel = AsyncChannel<String>()

    Task {
        try await Task.sleep(for: .milliseconds(1))
        // ends the for-await-loop
        channel.finish()
    }

    /// Sends an element to an **awaiting** iteration.
    Task {
        await channel.send("hello")
    }

    var values: [String] = []
    // the for-await-loop will wait for values, until the channel is manually finished
    for await value in channel {
        values.append(value)
    }

    #expect(values == ["hello"])
}
