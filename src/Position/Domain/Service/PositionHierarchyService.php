<?php

declare(strict_types=1);

namespace App\Position\Domain\Service;

use App\Position\Domain\Position;

class PositionHierarchyService
{
    /**
     * Check if position1 is subordinate to position2
     */
    public function isSubordinate(Position $position1, Position $position2): bool
    {
        return $position1->getLevel()->getValue() < $position2->getLevel()->getValue();
    }
    
    /**
     * Check if positions are at the same level
     */
    public function isSameLevel(Position $position1, Position $position2): bool
    {
        return $position1->getLevel()->getValue() === $position2->getLevel()->getValue();
    }
    
    /**
     * Get level difference between positions (positive if position2 is higher)
     */
    public function getLevelDifference(Position $position1, Position $position2): int
    {
        return $position2->getLevel()->getValue() - $position1->getLevel()->getValue();
    }
    
    /**
     * Check if position can be promoted directly to target (only 1 level up)
     */
    public function canBePromotedDirectly(Position $from, Position $to): bool
    {
        $difference = $this->getLevelDifference($from, $to);
        return $difference === 1;
    }
    
    /**
     * Check if positions are in the same department
     */
    public function isSameDepartment(Position $position1, Position $position2): bool
    {
        $dept1 = $position1->getDepartment();
        $dept2 = $position2->getDepartment();
        
        if ($dept1 === null || $dept2 === null) {
            return false;
        }
        
        return $dept1->equals($dept2);
    }
    
    /**
     * Get hierarchy path from one position to another
     * @param Position[] $availablePositions
     * @return Position[]
     */
    public function getHierarchyPath(
        Position $from, 
        Position $to, 
        array $availablePositions
    ): array {
        $fromLevel = $from->getLevel()->getValue();
        $toLevel = $to->getLevel()->getValue();
        
        // Can only go up in hierarchy
        if ($fromLevel >= $toLevel) {
            return [];
        }
        
        // Create a map of levels to positions
        $levelMap = [];
        foreach ($availablePositions as $position) {
            $level = $position->getLevel()->getValue();
            if (!isset($levelMap[$level])) {
                $levelMap[$level] = [];
            }
            $levelMap[$level][] = $position;
        }
        
        // Build path
        $path = [];
        
        // Add starting position
        $path[] = $from;
        
        // Add intermediate positions
        for ($level = $fromLevel + 1; $level < $toLevel; $level++) {
            if (!isset($levelMap[$level]) || empty($levelMap[$level])) {
                // Missing level in path
                return [];
            }
            // Take first position at this level (in real app, would need better logic)
            $path[] = $levelMap[$level][0];
        }
        
        // Add target position
        $path[] = $to;
        
        return $path;
    }
} 