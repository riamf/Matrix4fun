import Foundation

typealias Value = Double
typealias Vector = [Value]
typealias Matrix = [Vector]

public struct Constants {
    static var stopWords: [String] = {
        if let path = Bundle.main.path(forResource: "stopwords", ofType: "csv"),
            let content = try? String(contentsOfFile: path) {
            return content.split(separator: ",").map({ String($0) })
        }
        return []
    }()
}

extension Array where Element: Equatable {
    func counts(item: Element) -> Int {
        return filter({ $0 == item }).count
    }

    func uniques() -> [Element] {
        let ordered = NSOrderedSet(array: self)
        return ordered.array as! [Element]
    }
}

extension Int {
    var value: Value {
        return Value(self)
    }
}

class Preprocessor {
    private var minLength: Int
    private var lowercase: Bool
    private var stopWords: Bool
    init(minLength: Int = 1,
         lowercase: Bool = true,
         stopWords: Bool = false) {
        self.minLength = minLength
        self.lowercase = lowercase
        self.stopWords = stopWords
    }

    /**
     Takes list of documents and splits it into list of arrays of words
     Filters it stop wrods and minimum length of word
     - parameters:
        - lines: type of [String]
     */
    func fit(_ lines: [String]) -> [[String]] {
        let result = lines
            .map({ $0.split(separator: " ") })
            .map({
                $0.map({ lowercase ? String($0).lowercased() : String($0) })
                    .filter({ $0.count > minLength })
            })

        return stopWords
            ? result.map({ $0.filter({ !Constants.stopWords.contains($0) }) })
            : result
    }
}

class CountVectorizer {

    private var vocabulary: [String] = []
    init() {}

    /**
    Takes list of documents [[String]]
     - parameters:
        - sentences: type of [[String]]
     - returns:
     An 2d dense matrix containing count word per document
     where row is document and column is word
     */
    func fit(_ lines: [Any]) -> Matrix {
        guard let lines = lines as? [[String]] else {
            fatalError("Data type mismatch.")
        }
        let words = lines.reduce([],+)

        vocabulary = words.uniques().sorted()
        var counts = Matrix()
        for line in lines {
            var count = Vector()
            for v in vocabulary {
                count.append(line.counts(item: v).value)
            }
            counts.append(count)
        }
        return counts
    }
}

class TfidfTransformer {

    enum Norm {
        case l2
        case none
    }

    private var smoothIdf = false
    private var norm: Norm = .none

    private var normalization: ()

    init(smoothIdf: Bool = false,
         norm: Norm = .none) {
        self.smoothIdf = smoothIdf
        self.norm = norm
    }

    func fit(_ lines: Matrix) -> Matrix {

        var result = Matrix()
        for line in lines {
            var lineResult = Vector()
            for idx in (0..<line.count) {
                let tfidfValue = tf(document: line, idx: idx) * idf_smooth(idx: idx, documents: lines)
                lineResult.append(tfidfValue)
            }
            result.append(lineResult)
        }
        if norm == .none {
            return result
        } else {
            return l2norm(result)
        }
    }

    private func l2norm(_ input: Matrix) -> Matrix {
        var results = Matrix()
        for doc in input {
            let x_ = sqrt(doc.map({ pow($0, 2.0) }).reduce(0, +))
            var partial = Vector()
            for word in doc {
                partial.append(word/x_)
            }
            results.append(partial)
        }

        return results
    }

    private func tf(document: Vector, idx: Int) -> Value {
        return document[idx]
    }

    private func idf(idx: Int, documents: Matrix) -> Value {
        let nDocuments = documents.count.value
        var counts: Value = 0
        for document in documents {
            counts += document[idx] > 0 ? 1:0
        }

        return log(nDocuments/counts) + 1
    }

    private func idf_smooth(idx: Int, documents: Matrix) -> Value {
        let nDocuments = documents.count.value
        var counts: Value = 0
        for document in documents {
            counts += document[idx] > 0.0 ? 1.0:0.0
        }

        return log((1+nDocuments)/(counts + 1)) + 1
    }
}

let lines = ["alice cat has a cat",
             "cats are nice",
             "my cat is gray",
             "dogs are awesome"]

let cv = CountVectorizer().fit(Preprocessor().fit(lines))
cv.forEach {
    print($0)
}
print("")
let tf = TfidfTransformer(norm: .l2).fit(cv)

tf.forEach {
    print($0)
}


