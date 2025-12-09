//
//  LeaderboardRecord.swift
//  DivideNumber
//
//  Leaderboard score record model
//

import Foundation

/// Represents a single leaderboard entry
struct LeaderboardRecord: Codable, Comparable {
    let achievedScore: Int
    let timestampEpoch: TimeInterval
    let difficultyTier: LabyrinthDifficulty

    init(achievedScore: Int, difficultyTier: LabyrinthDifficulty) {
        self.achievedScore = achievedScore
        self.timestampEpoch = Date().timeIntervalSince1970
        self.difficultyTier = difficultyTier
    }

    /// Formatted date string
    var formattedChronology: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: Date(timeIntervalSince1970: timestampEpoch))
    }

    /// Compare records by score (descending)
    static func < (lhs: LeaderboardRecord, rhs: LeaderboardRecord) -> Bool {
        return lhs.achievedScore > rhs.achievedScore
    }
}
