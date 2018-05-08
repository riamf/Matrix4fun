import XCTest
import Matrix4fun

class Matrix4funTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreation() {
        let matrix: Matrix? = Matrix([[1],[2,3],[4]])
        XCTAssert(matrix != nil, "matrix is created")
    }

    func testEquality() {
        var m1 = Matrix([])
        var m2 = Matrix([])
        XCTAssert(m1 == m2, "should be equal")

        m1 = Matrix([[1],[2]])
        XCTAssertFalse(m1 == m2, "should not equal")

        m2 = Matrix([[1,2],[2]])
        XCTAssertFalse(m1 == m2, "should not equal")

        m1 = Matrix([[1,2],[2]])

        XCTAssert(m1 == m2, "should equal")
    }

    func testAddingMatrix() {

        var m1 = Matrix([])
        var m2 = Matrix([[1]])
        var m3 = m1 + m2
        XCTAssertNil(m3, "should be nil casue inequality in dimensions")

        m1 = Matrix([[1,1],[2,2],[3,3]])
        m2 = Matrix([[1,1],[8,7],[13,9]])
        m3 = m1 + m2
        let expected = Matrix([[2,2],[10,9],[16,12]])
        XCTAssert(m3 == expected, "result should equal \(expected)")
    }

    func testSubstractingMatrix() {

        var m1 = Matrix([])
        var m2 = Matrix([[1]])
        var m3 = m1 - m2
        XCTAssertNil(m3, "should be nil casue inequality in dimensions")

        m1 = Matrix([[1,1],[2,2],[3,3]])
        m2 = Matrix([[1,1],[8,7],[13,9]])
        m3 = m1 - m2
        let expected = Matrix([[0,0],[-6,-5],[-10,-6]])
        XCTAssert(m3 == expected, "result should equal \(expected) got \(m3!)")
    }
}
