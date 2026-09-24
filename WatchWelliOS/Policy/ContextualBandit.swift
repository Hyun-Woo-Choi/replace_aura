import Foundation

/// LinUCB contextual bandit (disjoint model, one ridge regression per action).
final class ContextualBandit {
    private struct ArmState {
        var a: [[Double]]   // d x d, initialized to identity
        var b: [Double]     // d
    }

    let actions: [RecoveryAction]
    /// Exploration strength; start high and decay as data accumulates.
    var alpha: Double

    private var arms: [RecoveryAction: ArmState]
    private let d: Int

    init(actions: [RecoveryAction], featureCount: Int, alpha: Double = 1.0) {
        self.actions = actions
        self.alpha = alpha
        d = featureCount
        let identity = (0..<featureCount).map { i in (0..<featureCount).map { $0 == i ? 1.0 : 0.0 } }
        arms = Dictionary(uniqueKeysWithValues: actions.map { ($0, ArmState(a: identity, b: Array(repeating: 0, count: featureCount))) })
    }

    func select(context: BanditContext) -> RecoveryAction {
        let x = context.features
        precondition(x.count == d, "Feature vector size mismatch")
        return actions.max { ucb(for: $0, x: x) < ucb(for: $1, x: x) } ?? .noNotification
    }

    /// Reward: weighted HRV recovery + user feedback, computed by the caller.
    func update(action: RecoveryAction, context: BanditContext, reward: Double) {
        let x = context.features
        guard var arm = arms[action] else { return }
        for i in 0..<d {
            for j in 0..<d { arm.a[i][j] += x[i] * x[j] }
            arm.b[i] += reward * x[i]
        }
        arms[action] = arm
    }

    private func ucb(for action: RecoveryAction, x: [Double]) -> Double {
        guard let arm = arms[action], let aInv = Self.invert(arm.a) else { return 0 }
        let theta = Self.multiply(aInv, arm.b)
        let mean = zip(theta, x).map(*).reduce(0, +)
        let aInvX = Self.multiply(aInv, x)
        let variance = zip(x, aInvX).map(*).reduce(0, +)
        return mean + alpha * max(variance, 0).squareRoot()
    }

    // MARK: - Small linear algebra helpers (d is tiny, so Gauss-Jordan is fine)

    private static func multiply(_ m: [[Double]], _ v: [Double]) -> [Double] {
        m.map { row in zip(row, v).map(*).reduce(0, +) }
    }

    private static func invert(_ m: [[Double]]) -> [[Double]]? {
        let n = m.count
        var a = m
        var inv = (0..<n).map { i in (0..<n).map { $0 == i ? 1.0 : 0.0 } }
        for col in 0..<n {
            guard let pivot = (col..<n).max(by: { abs(a[$0][col]) < abs(a[$1][col]) }),
                  abs(a[pivot][col]) > 1e-12 else { return nil }
            a.swapAt(col, pivot)
            inv.swapAt(col, pivot)
            let p = a[col][col]
            for j in 0..<n { a[col][j] /= p; inv[col][j] /= p }
            for row in 0..<n where row != col {
                let f = a[row][col]
                guard f != 0 else { continue }
                for j in 0..<n {
                    a[row][j] -= f * a[col][j]
                    inv[row][j] -= f * inv[col][j]
                }
            }
        }
        return inv
    }
}
