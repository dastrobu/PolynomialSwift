//
// Created by Daniel Strobusch on 2019-04-27.
//

import XCTest
import AccelerateArray
@testable import PolynomialSwift

final class PiecewisePolynomialTests: XCTestCase {
    let d0: Polynomial<Double> = [0.0]
    let d1: Polynomial<Double> = [1.0]
    let d2: Polynomial<Double> = [2.0]

    let f0: Polynomial<Float> = [0.0]
    let f1: Polynomial<Float> = [1.0]
    let f2: Polynomial<Float> = [2.0]

    func testInsertionIndexOf() throws {
        XCTAssertEqual([].insertionIndexOf(1.0), -1)
        XCTAssertEqual([0.0, 1.0].insertionIndexOf(-1.0), -1)
        XCTAssertEqual([0.0, 1.0, 2.0].insertionIndexOf(1.0), 1)
        XCTAssertEqual([0.0].insertionIndexOf(0.0), 0)
        XCTAssertEqual([0.0, 1.0].insertionIndexOf(0.5), 1)
        XCTAssertEqual([0.0, 1.0].insertionIndexOf(1.0), 1)
        XCTAssertEqual([0.0, 1.0].insertionIndexOf(2.0), 2)
        XCTAssertEqual([0.0, 1.0, 2.0][1..<2].insertionIndexOf(0.0), 0)
        XCTAssertEqual([0.0, 1.0, 2.0][1...].insertionIndexOf(1.5), 2)
    }

    func testInsertionBetween() throws {
        XCTAssertEqual([0.0, 1.0, 2.0].insertionBetween(0.0)!.left, 0)
        XCTAssertEqual([0.0, 1.0, 2.0].insertionBetween(0.0)!.right, 1)

        XCTAssertEqual([0.0, 1.0, 2.0].insertionBetween(2.0)!.left, 1)
        XCTAssertEqual([0.0, 1.0, 2.0].insertionBetween(2.0)!.right, 2)

        XCTAssertEqual([0.0, 1.0, 2.0].insertionBetween(1.5)!.left, 1)
        XCTAssertEqual([0.0, 1.0, 2.0].insertionBetween(1.5)!.right, 2)

        XCTAssertEqual([0.0, 1.0, 2.0][1...].insertionBetween(1.5)!.left, 1)
        XCTAssertEqual([0.0, 1.0, 2.0][1...].insertionBetween(1.5)!.right, 2)
    }

    func testEvaluateEmpty() throws {
        let p: PiecewisePolynomial<Double> = PiecewisePolynomial(polynomials: [], breakpoints: [])
        XCTAssert(p.evaluate(42).isNaN)
        XCTAssertEqual(p.evaluate([0, 1, 2]).count, 3)
    }

    func testEvaluateDouble() throws {
        let p = PiecewisePolynomial(polynomials: [d0, d1], breakpoints: [0.0, 1.0, 2.0])
        XCTAssertEqual(p.evaluate(0.0), 0.0)
    }

    func testEvaluateFloat() throws {
        let p = PiecewisePolynomial(polynomials: [f0, f1], breakpoints: [0.0, 1.0, 2.0])
        XCTAssertEqual(p.evaluate(0.0), 0.0)
    }

    func testEvaluateDoubleArray() throws {
        let p = PiecewisePolynomial(polynomials: [d0, d1], breakpoints: [0.0, 1.0, 2.0])
        let x: [Double] = [-1, 0, 1, 2, 3]
        let y: [Double] = p.evaluate(x)
        XCTAssertEqual(y[1..<4], [0.0, 1.0, 1.0])
        XCTAssert(y[0].isNaN)
        XCTAssert(y[4].isNaN)

        let q = PiecewisePolynomial(polynomials: [d0, d1, d2], breakpoints: [0, 1, 3, 7])
        XCTAssertEqual(q.evaluate(Array(step: 0.7, n: 6)), [0, 0, 1, 1, 1, 2])
    }

    func testEvaluateFloatArray() throws {
        let p = PiecewisePolynomial(polynomials: [f0, f1], breakpoints: [0.0, 1.0, 2.0])
        let x: [Float] = [-1, 0, 1, 2, 3]
        let y: [Float] = p.evaluate(x)
        XCTAssertEqual(y[1..<4], [0.0, 1.0, 1.0])
        XCTAssert(y[0].isNaN)
        XCTAssert(y[4].isNaN)

        let q = PiecewisePolynomial(polynomials: [f0, f1, f2], breakpoints: [0, 1, 3, 7])
        XCTAssertEqual(q.evaluate(Array(step: 0.7, n: 6)), [0, 0, 1, 1, 1, 2])
    }
}
