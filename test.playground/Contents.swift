import Foundation

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
    var double: Double {
        return Double(self)
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
    func fit(_ lines: [Any]) -> [Any] {
        guard let lines = lines as? [String] else {
            fatalError("Data type mismatch.")
        }
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
    func fit(_ lines: [Any]) -> [[Int]] {
        guard let lines = lines as? [[String]] else {
            fatalError("Data type mismatch.")
        }
        let words = lines.reduce([],+)

        vocabulary = words.uniques().sorted()
        var counts = [[Int]]()
        for line in lines {
            var count = [Int]()
            for v in vocabulary {
                count.append(line.counts(item: v))
            }
            counts.append(count)
        }
        return counts
    }
}

class TfidfTransformer {

    func fit(_ lines: [Any]) -> [[Double]] {
        guard let lines = lines as? [[Int]] else {
            fatalError("Expected counts array")
        }
        var result = [[Double]]()
        for line in lines {
            var lineResult = [Double]()
            for idx in (0..<line.count) {
                let tfidfValue = tf(document: line, idx: idx) * idf(idx: idx, documents: lines)
                lineResult.append(tfidfValue)
            }
            result.append(lineResult)
        }
        return result
    }

    private func tf(document: [Int], idx: Int) -> Double {
        let words = document.filter({ $0 > 0 }).count
        return words > 0 ? document[idx].double/words.double : 0.0
    }

    private func idf(idx: Int, documents: [[Int]]) -> Double {
        let nDocuments = documents.count.double
        var counts: Double = 0
        for document in documents {
            counts += document[idx].double
        }
        return log2(nDocuments/counts)
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
let tf = TfidfTransformer().fit(cv)

tf.forEach {
    print($0)
}

print(log(2.0))

