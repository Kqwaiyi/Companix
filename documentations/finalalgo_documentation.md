# Placement Algorithm Documentation

This document explains the current placement algorithms used in Cat Game and Snake Tower to determine a player's rank based on their performance (score or time).

## Cat Game (`end_screen.gd`)
The Cat Game uses a score-based placement algorithm, where higher scores result in better ranks.

### Top Placements (1st - 8th)
The top 8 places are determined by fixed score thresholds:
- **1st Place:** Score \(\ge\) 15,500
- **2nd Place:** Score \(\ge\) 14,500
- **3rd Place:** Score \(\ge\) 14,000
- **4th Place:** Score \(\ge\) 13,000
- **5th Place:** Score \(\ge\) 12,000
- **6th Place:** Score \(\ge\) 10,500
- **7th Place:** Score \(\ge\) 9,000
- **8th Place:** Score \(\ge\) 7,000

### 9th Place and Below
For any score below 7,000, the placement drops off quadratically. The formula used is:

```
Place = 8 + floor( ((7000 - Score) / 80)^2 )
```

This means that for every 80 points below 7,000, the penalty to your placement increases exponentially. The final rank is then clamped to a maximum of 10,000. 

> [!NOTE]
> For example, a score of 6,920 (80 points short of 7,000) places the player in 9th place (`8 + 1^2`). A score of 6,200 (800 points short) places the player in 108th place (`8 + 10^2`).

---

## Snake Tower (`LevelLast.gd`)
The Snake Tower uses a time-based placement algorithm, where lower times (faster completion) result in better ranks.

### Top Placements (1st - 8th)
The top 8 places are determined by fixed time thresholds (in seconds):
- **1st Place:** Time \(\le\) 480 seconds (8 minutes)
- **2nd Place:** Time \(\le\) 540 seconds (9 minutes)
- **3rd Place:** Time \(\le\) 660 seconds (11 minutes)
- **4th Place:** Time \(\le\) 780 seconds (13 minutes)
- **5th Place:** Time \(\le\) 900 seconds (15 minutes)
- **6th Place:** Time \(\le\) 1050 seconds (17.5 minutes)
- **7th Place:** Time \(\le\) 1200 seconds (20 minutes)
- **8th Place:** Time \(\le\) 1500 seconds (25 minutes)

### 9th Place and Below
For any completion time greater than 1500 seconds (25 minutes), the placement drops off quadratically based on how much extra time was taken. The formula used is:

```
Place = 8 + floor( ((Time - 1500) / 60)^2 * 5 )
```

This means that for every 60 seconds (1 minute) over the 25-minute mark, the penalty to your placement increases exponentially and is scaled by a factor of 5. The final rank is then clamped to a maximum of 10,000.

> [!NOTE]
> For example, finishing in 26 minutes (1560 seconds, which is 60 seconds over) places the player in 13th place (`8 + 1^2 * 5`). Finishing in 30 minutes (1800 seconds, which is 300 seconds over) places the player in 133rd place (`8 + 5^2 * 5`).
