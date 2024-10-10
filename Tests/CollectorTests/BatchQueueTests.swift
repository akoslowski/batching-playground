import Foundation
import Testing
import AsyncAlgorithms

@testable import Collector

@Test func testChunksOfBatches() async throws {
    let q = StreamQueue<String>()

    q.push("1")
    q.push("2")
    q.push("3")

    q.push("4")
    q.push("5")
    q.push("6")

    q.push("7")
    q.push("8")
    q.push("9")

    q.push("10")
    q.push("11")

    var batches: [[String]] = []
    for await batch in q.chunks(ofCount: 3, or: .repeating(every: .milliseconds(5))).prefix(4) {
        batches.append(batch)
    }

    try #require(batches.count == 4)
    #expect(batches[0] == ["1", "2", "3"])
    #expect(batches[1] == ["4", "5", "6"])
    #expect(batches[2] == ["7", "8", "9"])
    #expect(batches[3] == ["10", "11"])
}

@Test func testBatchQueueYieldsBatches() async throws {
    let q = BatchQueue<String>(timeout: .milliseconds(5))

    q.push("1")
    q.push("2")
    q.push("3")

    q.push("4")
    q.push("5")
    q.push("6")

    q.push("7")
    q.push("8")
    q.push("9")

    q.push("10")
    q.push("11")

    var batches: [[String]] = []
    for try await batch in q.prefix(4) {
        batches.append(batch)
    }

    try #require(batches.count == 4)
    #expect(batches[0] == ["1", "2", "3"])
    #expect(batches[1] == ["4", "5", "6"])
    #expect(batches[2] == ["7", "8", "9"])
    #expect(batches[3] == ["10", "11"])
}

@Test func testBatchQueueYieldsSingleBatch() async throws {
    let q = BatchQueue<String>(timeout: .milliseconds(5))

    q.push("1")

    var batches: [[String]] = []
    for try await batch in q.prefix(1) {
        batches.append(batch)
    }

    try #require(batches.count == 1)
    #expect(batches == [["1"]])
}

@Test func testBatchQueueYieldsBatchesOnMainActor() async throws {
    let q = BatchQueue<String>(timeout: .milliseconds(5))

    Task { @MainActor in
        q.push("1")
        q.push("2")
        q.push("3")
        q.push("4")
        q.push("5")
        q.push("6")
    }

    Task { @MainActor in
        q.push("7")
        q.push("8")
        q.push("9")
        q.push("10")
        q.push("11")
    }

    var batches: [[String]] = []
    for await batch in q.prefix(4) {
        batches.append(batch)
    }

    try #require(batches.count == 4)
    #expect(batches[0] == ["1", "2", "3"])
    #expect(batches[1] == ["4", "5", "6"])
    #expect(batches[2] == ["7", "8", "9"])
    #expect(batches[3] == ["10", "11"])
}

@Test func testBatchQueueYieldsBatchesOnAnyActor() async throws {
    let q = BatchQueue<String>(timeout: .milliseconds(5))

    Task {
        q.push("1")
        q.push("2")
        q.push("3")
        q.push("4")
        q.push("5")
        q.push("6")
    }

    Task {
        q.push("7")
        q.push("8")
        q.push("9")
        q.push("10")
        q.push("11")
    }

    var batches: [[String]] = []
    for await batch in q.prefix(4) {
        batches.append(batch)
    }

    try #require(batches.count == 4)
    // due to Task { ... }, the order of elements is random!
    #expect(batches[0].count == 3)
    #expect(batches[1].count == 3)
    #expect(batches[2].count == 3)
    #expect(batches[3].count == 2)
}
