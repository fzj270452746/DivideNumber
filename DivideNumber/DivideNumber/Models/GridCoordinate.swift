//
//  GridCoordinate.swift
//  DivideNumber
//
//  Board position coordinate model
//

import Foundation

/// Represents a position on the game board
struct GridCoordinate: Equatable, Hashable, Codable {
    let rowIndex: Int
    let columnIndex: Int

    /// Creates a coordinate at the specified row and column
    init(rowIndex: Int, columnIndex: Int) {
        self.rowIndex = rowIndex
        self.columnIndex = columnIndex
    }

    /// Returns the four adjacent coordinates (up, down, left, right)
    func adjacentQuadrant(withinBounds dimension: Int) -> [GridCoordinate] {
        var neighbors: [GridCoordinate] = []

        // Up
        if rowIndex > 0 {
            neighbors.append(GridCoordinate(rowIndex: rowIndex - 1, columnIndex: columnIndex))
        }
        // Down
        if rowIndex < dimension - 1 {
            neighbors.append(GridCoordinate(rowIndex: rowIndex + 1, columnIndex: columnIndex))
        }
        // Left
        if columnIndex > 0 {
            neighbors.append(GridCoordinate(rowIndex: rowIndex, columnIndex: columnIndex - 1))
        }
        // Right
        if columnIndex < dimension - 1 {
            neighbors.append(GridCoordinate(rowIndex: rowIndex, columnIndex: columnIndex + 1))
        }

        return neighbors
    }

    /// Check if this coordinate is within bounds
    func isWithinBounds(dimension: Int) -> Bool {
        return rowIndex >= 0 && rowIndex < dimension && columnIndex >= 0 && columnIndex < dimension
    }

    /// Returns a unique string key for this coordinate
    var lexiconKey: String {
        return "\(rowIndex)_\(columnIndex)"
    }
}
