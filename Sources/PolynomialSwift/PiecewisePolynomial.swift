internal extension RandomAccessCollection where Element: Comparable, Index == Int {
    /// find the insertion index of a new element in a sorted collection.
    /// if the collection is empty, startIndex - 1 is returned
    /// if the element to insert matches an element of the collection, the index of that element is returned
    /// if the element to insert is smaller than the first element of the collection, startIndex - 1 is returned
    /// if the element to insert is larger than the last element of the collection, endIndex is returned
    /// see https://stackoverflow.com/a/26679191/1458343
    func insertionIndexOf(_ x: Element) -> Index {
        var lo: Index = self.startIndex
        if isEmpty || x < self[lo] {
            return startIndex - 1
        }
        var hi: Index = self.endIndex - 1
        while lo <= hi {
            let mid = (lo + hi) / 2
            if self[mid] < x {
                lo = mid + 1
            } else if x < self[mid] {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }

    /// return the indices of the elements between which the new element should be inserted
    /// if the element cannot be inserted between two existent elements, without breaking the order of the array,
    /// nil is returned. This happens, when the element is smaller than the first element, or larger than the
    /// last element of the array.
    func insertionBetween(_ x: Element) -> (left: Index, right: Index)? {
        let k = insertionIndexOf(x)
        if k > self.startIndex && k < endIndex {
            return (left: k - 1, right: k)
        }
        if k == self.startIndex && self.startIndex != self.endIndex {
            return (left: k, right: k + 1)
        }
        return nil
    }
}

fileprivate extension Array where Element: FloatingPoint {
    var isStrictlyIncreasing: Bool {
        var result = true
        for i in 1..<count {
            result = result && self[i - 1] < self[i]
        }
        return result
    }
}

/// Class representing a piecewise polynomial.
open class PiecewisePolynomial<T> where T: FloatingPoint {
    public let polynomials: [Polynomial<T>]
    public let breakpoints: [T]

    /// Piecewise polynomial based on polynomials and breakpoints.
    ///
    /// Intervals defined by the breakpoints are half-open, [a, b), except for the last interval [a, b] which is closed.
    /// Breakpoints must be strictly increasing.
    /// Note that the first and last interval can be made open by defining the first breakpoint as -∞ and the last one
    /// as +∞, see FloatingPoint.infinity.
    public init(polynomials: [Polynomial<T>], breakpoints: [T]) {
        if polynomials.isEmpty {
            self.polynomials = []
            self.breakpoints = []
            return
        }
        assert(polynomials.count == breakpoints.count - 1, "\(polynomials.count) == \(breakpoints.count) - 1")
        assert(breakpoints.isStrictlyIncreasing)
        self.polynomials = polynomials
        self.breakpoints = breakpoints
    }

    // determine the interval in which x falls
    private func intervalOf(_ x: T) -> (left: Int, right: Int)? {
        // handle empty piecewise polynomial
        guard let last = breakpoints.last else {
            return nil
        }

        // handle special case where x is equal to the last breakpoint, i.e. because the last interval is closed
        if x == last {
            return (left: breakpoints.count - 2, breakpoints.count - 1)
        }
        return breakpoints.insertionBetween(x)
    }

    /// evaluate piecewise polynomial, any value outside the breakpoints will evaluate to nan, see FloatingPoint.nan.
    /// the values must be increasing, however not strictly
    fileprivate func evaluate(_ x: [T], evaluator: @escaping (Polynomial<T>, [T]) -> [T]) -> [T] {
        guard let lastBreakpoint = breakpoints.last else {
            // handle empty piecewise polynomial
            return Array<T>(repeating: T.nan, count: x.count)
        }

        // handle first point
        var intervalBounds = intervalOf(x[0])

        var interval = [x[0]]
        var y: [T] = []
        y.reserveCapacity(x.count)

        for i in 1..<x.count {
            let xi = x[i]
            if let lastBounds = intervalBounds {
                // check if next value is on the same interval (which is likely)
                // the case where xi == breakpoints.last can be ignored here
                if xi >= breakpoints[lastBounds.left] && xi < breakpoints[lastBounds.right] {
                    interval.append(xi)
                } else {
                    // evaluate last interval
                    y.append(contentsOf: evaluator(self.polynomials[lastBounds.left], interval))
                    // if x is ordered, search for the next interval on the remaining breakpoints
                    if xi > x[i - 1] && xi < lastBreakpoint {
                        // do ordered, search on the remaining breakpoints only
                        intervalBounds = breakpoints[lastBounds.right...].insertionBetween(xi)
                    }
                    // if x is unordered, not strictly increasing or xi falls on the last breakpoint start over
                    else {
                        intervalBounds = intervalOf(xi)
                    }
                    interval = [xi]
                }
            } else {
                assert(interval.count == 1, "\(interval.count) == 1")
                // last value in x was not on an interval, so evaluate to nan
                y.append(T.nan)
                // find next interval
                intervalBounds = intervalOf(xi)
                interval = [xi]
            }
        }
        // evaluate the last interval
        if let lastBounds = intervalBounds {
            y.append(contentsOf: evaluator(self.polynomials[lastBounds.left], interval))
        } else {
            assert(interval.count == 1, "\(interval.count) == 1")
            y.append(T.nan)
        }
        assert(x.count == y.count, "\(x.count) == \(y.count)")
        return y
    }

    /// return the mth derivative of the polynomial
    /// If the polynomial is empty, computing the derivative has no effect
    public func derivative(_ m: Int = 1) -> PiecewisePolynomial<T> {
        return PiecewisePolynomial(polynomials: polynomials.map {
            $0.derivative(m)
        }, breakpoints: breakpoints)
    }
}

public extension PiecewisePolynomial where T == Double {
    /// evaluate piecewise polynomial, any value outside the breakpoints will evaluate to nan, see FloatingPoint.nan.
    func evaluate(_ x: T) -> T {
        return evaluate([x])[0]
    }

    /// evaluate piecewise polynomial, any value outside the breakpoints will evaluate to nan, see FloatingPoint.nan.
    /// performance is best if x is ordered strictly increasing
    func evaluate(_ x: [T]) -> [T] {
        return evaluate(x) {
            $0.evaluate($1)
        }
    }
}

public extension PiecewisePolynomial where T == Float {
    /// evaluate piecewise polynomial, any value outside the breakpoints will evaluate to nan, see FloatingPoint.nan.
    func evaluate(_ x: T) -> T {
        return evaluate([x])[0]
    }

    /// evaluate piecewise polynomial, any value outside the breakpoints will evaluate to nan, see FloatingPoint.nan.
    /// performance is best if x is ordered strictly increasing
    func evaluate(_ x: [T]) -> [T] {
        return evaluate(x) {
            $0.evaluate($1)
        }
    }
}
