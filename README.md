# A place to play with Swift Concurrency

## Why?

On the way to Swift 6 we encountered some issues with keeping an interface for existing classes stable and internally using e.g. actors to isolate mutable state.

One issue is the usage of unstructured tasks, that bridge between a nonisolated function and the internal actor. While it works, testing becomes more complicated, because the tasks are out of control of the test.

A key feature we need to implement is the ability to receive event streams from the application and batch them into groups of n elements. If no events are received within a predefined time window, the system should trigger the emission of the current batch, even if incomplete. Each batch will then be transmitted to the server for further processing.

## Approaches

### Manually using `AsyncStream` to receive and chunk events

> `AsyncStream` introduced a mechanism to send buffered elements from a context that doesn't use Swift concurrency into one that does.
>
> Source: [AsyncAlgorithms](https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Channel.md)

tbd

### Using `chunks` from `swift-async-algorithms`

> https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Chunked.md

tbd

### Using `AsyncChannel` from `swift-async-algorithms`

> https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Channel.md

tbd

