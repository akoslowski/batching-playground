@testable import Collector
import Foundation
import Testing

@Test func queueAllTheThings() async throws {
    let q = BatchQueue()

    await q.push("1")
    await q.push("2")
    await q.push("3")

    await q.push("4")
    await q.push("5")
    await q.push("6")

    await q.push("7")
    await q.push("8")
    await q.push("9")

    await q.push("10")
    await q.push("11")

    var numberOfReceivedBatches = 0
    for await batch in await q.values {
        print(batch)
        numberOfReceivedBatches += 1
        if numberOfReceivedBatches == 4 {
            await q.cancel()
        }
    }

    #expect(numberOfReceivedBatches == 4)
}
