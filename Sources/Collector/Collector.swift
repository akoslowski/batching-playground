import Foundation


struct Streamer<Element: Sendable> {
    var stream: AsyncStream<Element>
    let continuation: AsyncStream<Element>.Continuation?

    public init() {
        var _continuation: AsyncStream<Element>.Continuation?
        stream = AsyncStream { continuation in
            _continuation = continuation
        }
        continuation = _continuation
    }

    func push(_ event: Element) {
        continuation?.yield(event)
    }

    func cancel() {
        continuation?.finish()
    }
}


public actor BatchQueue {

    enum Event {
        case element(String)
        case timeOut
    }

    private let incomingEvents: Streamer<Event> = .init()
    private let outgoingBatches: Streamer<[String]> = .init()
    private let worker: Task<Void, Never>
    private var timer: Task<Void, Never>?

    public var values: AsyncStream<[String]> {
        outgoingBatches.stream
    }

    public func cancel() {
        incomingEvents.cancel()
        outgoingBatches.cancel()
    }

    public nonisolated func push(_ event: String) {
        incomingEvents.push(.element(event))

    }

    func resetTimer() {
        timer?.cancel()
        timer = Task { [incomingEvents] in
            do {
                try await Task.sleep(for: .seconds(1))
                incomingEvents.push(.timeOut)
            } catch {
                // nothing
            }
        }
    }

    public init() {
//        timer = Task { [incomingEvents] in
//            do {
//                try await Task.sleep(for: .seconds(1))
//                incomingEvents.push(.timeOut)
//            } catch {
//                // nothing
//            }
//        }

        worker = Task { [incomingEvents, outgoingBatches] in
            var batch: [String] = []

            for await event in incomingEvents.stream {
                switch event {
                case .element(let string):
                    if batch.count < 3 {
                        batch.append(string)
                    } else {
                        outgoingBatches.push(batch)
                        batch = [string]
                    }

                case .timeOut:
                    outgoingBatches.push(batch)
                }

            }
        }
    }
}



final class CollectionAssistent {
    let collector: Collector
    private let stream: AsyncStream<String>
    private let continuation: AsyncStream<String>.Continuation?
    private let worker: Task<Void, Never>

    public init() {
        var _continuation: AsyncStream<String>.Continuation?
        stream = AsyncStream { continuation in
            _continuation = continuation
        }
        continuation = _continuation
        collector = Collector()
        worker = Task { [stream, collector] in
            for await value in stream {
                await collector.add(value)
            }
        }
    }

    func add(_ event: String) {
        continuation?.yield(event)
    }
}

actor Collector {
    private var events: [String] = []
    private var batchSize: Int = 3
    private var sender: Task<Void, Never>?
    var sent: [[String]] = []

    init() {}

    func add(_ event: String) async {
        print("enqueued event: \(event)")
        events.append(event)

        sender?.cancel()
        await sender?.value
        sender = nil

        sender = Task {
            do {
                try await Task.sleep(for: .seconds(1))
                await send()
            } catch {
                print("sender was cancelled with incoming event.")
            }
        }

        if events.count >= batchSize {
            await send()
        }
    }

    func send() async {
        do {
            try await Task.sleep(for: .seconds(1))

            if events.count >= batchSize {
                let batch = events.prefix(batchSize)
                events.removeFirst(batchSize)
                print("sending out batch: \(batch)")
                sent.append(Array(batch))
            } else {
                let batch = events
                events.removeAll()
                print("sending out remaining: \(batch)")
                sent.append(Array(batch))
            }
        } catch {
            print("Cancelled.")
        }
    }
}
