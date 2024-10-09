import Foundation
import Testing

@testable import Collector

@Test func testCollectByCount() async throws {
    let countdown = CountdownSequence(start: 5, delay: 0.1)
    let collected = countdown.collect(count: 3)

    var iterator = collected.makeAsyncIterator()

    let firstGroup = try await iterator.next()
    #expect(firstGroup == [5, 4, 3], "First group should contain [5, 4, 3]")

    let secondGroup = try await iterator.next()
    #expect(secondGroup == [2, 1], "Second group should contain [2, 1]")

    let thirdGroup = try await iterator.next()
    #expect(thirdGroup == nil, "Third group should be nil as the sequence is exhausted")
}

@Test func testCollectByTime() async throws {
    let countdown = CountdownSequence(start: 5, delay: 0.1)
    let collected = countdown.collect(every: 0.25)

    var iterator = collected.makeAsyncIterator()

    let firstGroup = try await iterator.next()
    #expect(firstGroup == [5, 4, 3], "First group should contain [5, 4, 3]")

    let secondGroup = try await iterator.next()
    #expect(secondGroup == [2, 1], "Second group should contain [2, 1]")

    let thirdGroup = try await iterator.next()
    #expect(thirdGroup == nil, "Third group should be nil as the sequence is exhausted")
}
