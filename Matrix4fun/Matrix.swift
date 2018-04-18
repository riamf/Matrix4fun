import Foundation

public typealias Vector = [Double]
public typealias Dimension = CGSize

extension Array where Element == Vector {

}

public struct Matrix {

    public var raw: [Vector]
    public var dimension: Dimension

    init() {
        raw = []
        dimension = .zero
    }

    public init(_ data: [Vector]) {
        raw = data
        let rows = data.count
        let columns = data.map({ $0.count }).max() ?? 0
        dimension = CGSize(width: columns, height: rows)
        dataCheck()
    }

    private mutating func dataCheck() {
        let colums = dimension.width.toInt

        for i in 0..<raw.count {
            if raw[i].count < colums {
                let toAppend = (0..<(colums-raw[i].count)).map({ _ in return 0.0 })
                raw[i].append(contentsOf: toAppend)
            }
        }
    }
}

extension Matrix {
    subscript(index: Int) -> Vector {
        get {
            return raw[index]
        }
        set {
            raw[index] = newValue
        }
    }
}

extension Matrix {
    public static func +(lhs:Matrix, rhs:Matrix) -> Matrix? {
        guard lhs.dimension == rhs.dimension else {
            return nil
        }
        let dim = lhs.dimension
        var vec = [Vector]()
        for i in (0..<dim.height.toInt) {
            var vec_ = Vector()
            for j in (0..<dim.width.toInt) {
                vec_.append(lhs[i][j]+rhs[i][j])
            }
            vec.append(vec_)
        }

        return Matrix(vec)
    }
}

extension Matrix: Equatable {
    public static func ==(lhs: Matrix, rhs: Matrix) -> Bool {
        guard lhs.dimension == rhs.dimension else {
            return false
        }
        return lhs.raw.elementsEqual(rhs.raw)
    }
}

extension Matrix: CustomStringConvertible {
    public var description: String {
        var desc = "DIMENSION \(dimension.width)X\(dimension.height)\n"
        desc += "["
        raw.forEach {
            desc += "["
            $0.forEach({ (i) in
                desc += "\(i),"
            })
            desc = String(desc.prefix(desc.count-1))
            desc += "]\n"
        }
        desc = String(desc.prefix(desc.count-1))
        desc += "]\n"
        return desc
    }
}


