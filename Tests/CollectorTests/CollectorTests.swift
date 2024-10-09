@testable import Collector
import Foundation
import Testing

struct CollectorTests {
    @Test func collectionAssistent() async throws {
        let c = CollectionAssistent()

        for i in 0 ..< 10 {
            let e = "\(i)"
            c.add(e)
        }

        c.add("11")
        try? await Task.sleep(for: .milliseconds(20))
        c.add("12")
        c.add("13")
        try? await Task.sleep(for: .milliseconds(20))
        c.add("14")
        c.add("15")
        c.add("16")
        c.add("17")

        try? await Task.sleep(for: .seconds(12))

        #expect(
            await c.collector.sent ==
            [
            ["0", "1", "2"],
            ["3", "4", "5"],
            ["6", "7", "8"],
            ["9", "11", "12"],
            ["13", "14", "15"],
            ["16", "17"]
            ]
        )
    }


    @Test func queueAllTheThings() async throws {
        let q = BatchQueue()


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

        var batches = 0
        for await e in await q.values {
            print(e)
            batches += 1
            if batches == 4 {
                await q.cancel()
            }
        }

    }
}
