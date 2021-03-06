import Accelerate

/// Class representing a polynomial.
open class Polynomial<T>: ExpressibleByArrayLiteral, CustomDebugStringConvertible
    where T: FloatingPoint {
    public let coefficients: [T]
    public let x0: T

    /// Degree of the polynomial, i.e. number of coefficients - 1
    /// If coefficients are empty, degree is -1.
    /// - SeeAlso: `trimmedDegree(...)`
    public var degree: Int {
        return coefficients.count - 1
    }

    /// Trimmed degree of the polynomial,
    /// i.e. number of coefficients - 1 without trailing coefficients ci where |ci| < tol.
    /// If coefficients are empty, degree is -1.
    /// - SeeAlso: `trimmed(...)`
    public func trimmedDegree(tol: T = 0) -> Int {
        assert(tol >= 0, "\(tol) >= 0")
        if coefficients.isEmpty {
            return -1
        }
        for i in (0..<coefficients.count).reversed() {
            if abs(coefficients[i]) > tol {
                return i
            }
        }
        // all coefficients are 0
        return 0
    }

    /// Trimmed polynomial,
    /// i.e. coefficients are trimmed where trailing coefficients |ci| < tol.
    /// If coefficients are empty, degree is 0.
    /// - SeeAlso: trimmedDegree(...)
    public func trimmed(tol: T = 0) -> Polynomial<T> {
        let d = trimmedDegree(tol: tol)
        if d == -1 {
            return Polynomial(coefficients: [], x0: x0)
        }
        return Polynomial(coefficients: coefficients[0...d], x0: x0)
    }

    /// create new polynomial with coefficients c[i] where polynomial is given by
    /// p(x) = sum_i x^i * c[i] = c[0] + x * c[1] + x^2 * c[2] + ...
    public init(coefficients: ArraySlice<T>, x0: T = 0) {
        self.coefficients = Array(coefficients)
        self.x0 = x0
    }

    /// create new polynomial with coefficients c[i] and shift x0 where polynomial is given by
    /// p(x) = sum_i (x - x0)^i * c[i] = c[0] + (x - x0) * c[1] + (x - x0)^2 * c[2] + ...
    public init(coefficients: [T], x0: T = 0) {
        self.coefficients = coefficients
        self.x0 = x0
    }

    /// convenience initializer to express polynomial by literal
    public required convenience init(arrayLiteral elements: T...) {
        self.init(coefficients: elements)
    }

    /// return the mth derivative of the polynomial
    /// If the polynomial is empty, an empty polynomial is returned.
    public func derivative(_ m: Int = 1) -> Polynomial<T> {
        assert(m >= 0, "\(m) >= 0")
        if m == 0 || coefficients.isEmpty {
            return Polynomial(coefficients: [], x0: x0)
        }

        let degree = self.degree
        if trimmedDegree() < degree {
            return trimmed().derivative(m)
        }

        if m >= coefficients.count {
            return Polynomial(coefficients: [0], x0: x0)
        }

        var c = coefficients
        for i in 0..<m {
            for j in 1...degree - i {
                c[j - 1] = T(j) * c[j]
            }
        }
        return Polynomial(coefficients: c[0..<(c.count - m)], x0: x0)
    }

    public var debugDescription: String {
        return "Polynomial(\(coefficients), x0=\(x0))"
    }
}

/// extension for polynomial with double precision elements
public extension Polynomial where T == Double {
    /// evaluate polynomial at a single point x
    func evaluate(_ x: T) -> T {
        return evaluate([x])[0]
    }

    /// evaluate polynomial at an array of points
    func evaluate(_ x: [T]) -> [T] {
        if coefficients.isEmpty {
            return Array(repeating: T.nan, count: x.count)
        }
        let degree = coefficients.count - 1
        let xx = x.map {
            $0 - x0
        }
        var c = [T](repeating: 0, count: x.count)
        coefficients.withUnsafeBufferPointer { p in
            vDSP_vpolyD(p.baseAddress! + degree, -1, xx, 1, &c, 1, vDSP_Length(x.count), vDSP_Length(degree))
        }
        return c
    }
}

/// extension for polynomial with single precision elements
public extension Polynomial where T == Float {
    /// evaluate polynomial at a single point x
    func evaluate(_ x: T) -> T {
        return evaluate([x])[0]
    }

    /// evaluate polynomial at an array of points
    func evaluate(_ x: [T]) -> [T] {
        if coefficients.isEmpty {
            return Array(repeating: T.nan, count: x.count)
        }
        let degree = coefficients.count - 1
        let xx = x.map {
            $0 - x0
        }
        var c = [T](repeating: 0, count: x.count)
        coefficients.withUnsafeBufferPointer { p in
            vDSP_vpoly(p.baseAddress! + degree, -1, xx, 1, &c, 1, vDSP_Length(x.count), vDSP_Length(degree))
        }
        return c
    }
}
