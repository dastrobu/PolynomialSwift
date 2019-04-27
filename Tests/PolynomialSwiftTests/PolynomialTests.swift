//
// Created by Daniel Strobusch on 2019-04-27.
//

@testable import PolynomialSwift

import XCTest
@testable import PolynomialSwift

final class PolynomialTests: XCTestCase {
    func testTrimmedDegree() throws {
        XCTAssertEqual(Polynomial<Double>(coefficients: []).trimmedDegree(), -1)
        XCTAssertEqual(Polynomial<Double>(coefficients: [1]).trimmedDegree(), 0)
        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 0]).trimmedDegree(), 0)
        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 1]).trimmedDegree(), 1)
        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 1, 1e-15]).trimmedDegree(tol: 1e-15), 1)
        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 1, 1e-15]).trimmedDegree(tol: 2e-15), 1)
    }

    func testTrimmed() throws {
        XCTAssertEqual(Polynomial<Double>(coefficients: []).trimmed().coefficients, [])
        XCTAssertEqual(Polynomial<Double>(coefficients: [1]).trimmed().coefficients, [1])
        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 0]).trimmed().coefficients, [1])
        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 1]).trimmed().coefficients, [1, 1])
        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 1, 2e-15]).trimmed(tol: 1e-15).coefficients, [1, 1, 2e-15])
        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 1, 1e-15]).trimmed(tol: 1e-15).coefficients, [1, 1])
    }

    func testDerivative() throws {
        XCTAssertEqual(Polynomial<Double>(coefficients: []).derivative().coefficients, [])
        XCTAssertEqual(Polynomial<Double>(coefficients: [1]).derivative().coefficients, [0])
        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 0]).derivative().coefficients, [0])
        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 1]).derivative().coefficients, [1])
        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 2, 3]).derivative().coefficients, [2, 6])
        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 2, 3]).derivative(2).coefficients, [6])
        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 2, 3]).derivative(3).coefficients, [0])
        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 2, 3]).derivative(4).coefficients, [0])
    }

    func testEvalArrayDouble() throws {
        XCTAssertEqual(Polynomial<Double>(coefficients: []).evaluate([0, 1, 2]).count, 3)
        XCTAssert(Polynomial<Double>(coefficients: []).evaluate([0, 1, 2])[0].isNaN)
        XCTAssert(Polynomial<Double>(coefficients: []).evaluate([0, 1, 2])[1].isNaN)
        XCTAssert(Polynomial<Double>(coefficients: []).evaluate([0, 1, 2])[2].isNaN)

        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 2, 3]).evaluate([0, 1, 2]), [1, 6, 17])
        XCTAssertEqual(Polynomial<Double>(coefficients: [1, 2, 3, 4]).evaluate([1, 2]), [10, 49])
        XCTAssertEqual(Polynomial<Double>(coefficients: [2, 3], x0: 3).evaluate([1, 2]), [-4, -1])
    }

    func testEvalArrayFloat() throws {
        XCTAssertEqual(Polynomial<Float>(coefficients: []).evaluate([0, 1, 2]).count, 3)
        XCTAssert(Polynomial<Float>(coefficients: []).evaluate([0, 1, 2])[0].isNaN)
        XCTAssert(Polynomial<Float>(coefficients: []).evaluate([0, 1, 2])[1].isNaN)
        XCTAssert(Polynomial<Float>(coefficients: []).evaluate([0, 1, 2])[2].isNaN)

        XCTAssertEqual(Polynomial<Float>(coefficients: [1, 2, 3]).evaluate([0, 1, 2]), [1, 6, 17])
        XCTAssertEqual(Polynomial<Float>(coefficients: [1, 2, 3, 4]).evaluate([1, 2]), [10, 49])
        XCTAssertEqual(Polynomial<Float>(coefficients: [2, 3], x0: 3).evaluate([1, 2]), [-4, -1])
    }
}

