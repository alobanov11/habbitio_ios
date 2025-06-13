import Foundation

struct Command<Args, T>: Hashable {

    let id: UUID
    let file: StaticString
    let function: StaticString
    let line: Int
    let action: (Args) -> T

    init(
        id: UUID = UUID(),
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line,
        action: @escaping (Args) -> T
    ) {
        self.id = id
        self.file = file
        self.function = function
        self.line = line
        self.action = action
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Command<Args, T>, rhs: Command<Args, T>) -> Bool {
        lhs.id == rhs.id
    }

    func callAsFunction(_ args: Args) -> T {
        action(args)
    }
}

extension Command where Args == Void {

    func callAsFunction() -> T {
        action(())
    }
}

extension Command where T == Void {

    static var empty: Command<Args, T> {
        .init { _ in }
    }
}

typealias CommandVoid = Command<Void, Void>
typealias CommandWith<T> = Command<T, Void>
