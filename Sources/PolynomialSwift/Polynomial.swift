//
// Created by Daniel Strobusch on 2019-04-18.
//

import AccelerateArray

open class Polynomial<T> where T: FloatingPoint {
    public let coefficients: [T]
    public let x0: T

    public init(coefficients: [T], x0: T = 0) {
        self.coefficients = coefficients
        self.x0 = x0
    }
}

public extension Polynomial where T == Double {
    func evaluate(_ x: T) -> T {
        return evaluate([x])[0]
    }

    func evaluate(_ x: [T]) -> [T] {
        return coefficients.vpoly(x.map {
            $0 - x0
        })
    }
}

public extension Polynomial where T == Float {
    func evaluate(_ x: T) -> T {
        return evaluate([x])[0]
    }

    func evaluate(_ x: [T]) -> [T] {
        return coefficients.vpoly(x.map {
            $0 - x0
        })
    }
}
