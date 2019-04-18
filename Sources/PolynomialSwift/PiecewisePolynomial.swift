//
// Created by Daniel Strobusch on 2019-04-18.
//

/// see https://stackoverflow.com/a/26679191/1458343
fileprivate extension RandomAccessCollection where Element: Comparable, Index == Int {
    func insertionIndexOf(_ elem: Element) -> Index {
        var lo: Index = self.startIndex
        var hi: Index = self.endIndex
        while lo <= hi {
            let mid = (lo + hi) / 2
            if self[mid] < elem {
                lo = mid + 1
            } else if elem < self[mid] {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
}

fileprivate extension Array where Element: FloatingPoint {
    var isIncreasing: Bool {
        var result = true
        for i in 1..<count {
            result = result && self[i - 1] < self[i]
        }
        return result
    }
}

public enum PiecewisePolynomialError<Element>: Error {
    case orderError(data: [Element])
}

open class PiecewisePolynomial<T> where T: FloatingPoint {
    public let polynomials: [Polynomial<T>]
    public let breakpoints: [T]

    /// intervals defined by the breakpoints are half-open, [a, b), except for the last interval [a, b] which is closed.
    public init(polynomials: [Polynomial<T>], breakpoints: [T],
                extrapolation: Bool = true) throws {
        assert(polynomials.count == breakpoints.count - 1, "\(polynomials.count) == \(breakpoints.count) - 1")
        if !breakpoints.isIncreasing {
            throw PiecewisePolynomialError.orderError(data: breakpoints)
        }
        self.polynomials = polynomials
        self.breakpoints = breakpoints
    }

    fileprivate func evaluate(_ x: [T], evaluator: @escaping (Polynomial<T>, [T]) -> [T]) -> [T] {
        if x.isEmpty {
            return []
        }

        var k = breakpoints.insertionIndexOf(x[0])
        var interval = [x[0]]
        var y: [T] = []
        y.reserveCapacity(x.count)

        for i in 1..<x.count {
            let xi = x[i]
            // check if next value is on the same interval
            if k < breakpoints.count - 1 && breakpoints[k] <= xi && xi < breakpoints[k + 1] {
                interval.append(xi)
            }
            // special case where xi is exactly on the last break point
            if k == breakpoints.count - 1 && breakpoints[k] == xi {
                interval.append(xi)
            }
            // xi is on a different interval
            else {
                y.append(contentsOf: evaluator(self.polynomials[k - 1], interval))
                // if ordered, search on the remaining breakpoints only
                if xi >= x[i - 1] {
                    k = breakpoints[k..<breakpoints.count].insertionIndexOf(xi)
                } else {
                    k = breakpoints[0..<k].insertionIndexOf(xi)
                }
                interval = [xi]
            }
        }
        // evaluate the last interval
        y.append(contentsOf: evaluator(self.polynomials[k - 1], interval))
        return y
    }
}

public extension PiecewisePolynomial where T == Double {
    func evaluate(_ x: T) -> T {
        return evaluate([x])[0]
    }

    func evaluate(_ x: [T]) -> [T] {
        return evaluate(x) {
            $0.evaluate($1)
        }
    }
}

public extension PiecewisePolynomial where T == Float {
    func evaluate(_ x: T) -> T {
        return evaluate([x])[0]
    }

    func evaluate(_ x: [T]) -> [T] {
        return evaluate(x) {
            $0.evaluate($1)
        }
    }
}
