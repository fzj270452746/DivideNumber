//
//  ArchivalVaultManager.swift
//  DivideNumber
//
//  Manages persistent data storage
//

import Foundation

/// Singleton manager for persistent data storage
class ArchivalVaultManager {

    // MARK: - Singleton

    static let shared = ArchivalVaultManager()

    private init() {}

    // MARK: - UserDefaults Keys

    private enum VaultKey {
        static let highScorePrefix = "zenith_score_"
        static let leaderboardPrefix = "chronicle_"
        static let maxLeaderboardEntries = 10
    }

    // MARK: - High Score Methods

    /// Gets the high score for a difficulty
    func retrieveZenithScore(for difficulty: LabyrinthDifficulty) -> Int {
        let key = VaultKey.highScorePrefix + difficulty.archiveKeyDesignation
        return UserDefaults.standard.integer(forKey: key)
    }

    /// Saves a new high score if it's higher than the current one
    func updateZenithScore(_ score: Int, for difficulty: LabyrinthDifficulty) {
        let currentHigh = retrieveZenithScore(for: difficulty)
        if score > currentHigh {
            let key = VaultKey.highScorePrefix + difficulty.archiveKeyDesignation
            UserDefaults.standard.set(score, forKey: key)
        }
    }

    // MARK: - Leaderboard Methods

    /// Gets all leaderboard records for a difficulty
    func retrieveChronicle(for difficulty: LabyrinthDifficulty) -> [LeaderboardRecord] {
        let key = VaultKey.leaderboardPrefix + difficulty.archiveKeyDesignation

        guard let data = UserDefaults.standard.data(forKey: key),
              let records = try? JSONDecoder().decode([LeaderboardRecord].self, from: data) else {
            return []
        }

        return records.sorted()
    }

    /// Saves a score to the leaderboard
    func preserveScore(_ score: Int, for difficulty: LabyrinthDifficulty) {
        // Update high score
        updateZenithScore(score, for: difficulty)

        // Add to leaderboard
        var records = retrieveChronicle(for: difficulty)
        let newRecord = LeaderboardRecord(achievedScore: score, difficultyTier: difficulty)
        records.append(newRecord)

        // Sort and trim to max entries
        records.sort()
        if records.count > VaultKey.maxLeaderboardEntries {
            records = Array(records.prefix(VaultKey.maxLeaderboardEntries))
        }

        // Save
        let key = VaultKey.leaderboardPrefix + difficulty.archiveKeyDesignation
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    /// Clears all leaderboard data for a difficulty
    func purgeChronicle(for difficulty: LabyrinthDifficulty) {
        let highScoreKey = VaultKey.highScorePrefix + difficulty.archiveKeyDesignation
        let leaderboardKey = VaultKey.leaderboardPrefix + difficulty.archiveKeyDesignation

        UserDefaults.standard.removeObject(forKey: highScoreKey)
        UserDefaults.standard.removeObject(forKey: leaderboardKey)
    }

    /// Clears all game data
    func purgeAllData() {
        for difficulty in LabyrinthDifficulty.allCases {
            purgeChronicle(for: difficulty)
        }
    }
}
