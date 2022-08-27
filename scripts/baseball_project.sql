--1.What range of years for baseball games played does the provided database cover?
SELECT MIN(debut), MAX(finalgame)
FROM people
--Date Range: 1871-2017

--2.Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
Select namegiven, height, teamid, g_all
FROM people
LEFT JOIN appearances as a
USING(playerid)
WHERE height = 43
--Total Games: 1 game (debut and finalgame are identital dates), TEAM: SLA (Saint Louis Browns)

--3. Find all players in the database who played at Vanderbilt University. First/Last names, total salary in Maj. league, sort DESC tots. sal 
--Which Vanderbilt player earned the most money in the majors? 
SELECT namefirst, namelast, cp.schoolid, schoolname, MONEY(CAST(SUM(DISTINCT salary) AS numeric)) AS total_salary
FROM collegeplaying as cp
JOIN people
USING(playerid)
JOIN salaries 
USING(playerid)
JOIN schools AS s
ON cp.schoolid = s.schoolid
WHERE cp.schoolid = 'vandy' AND schoolname = 'Vanderbilt University'
GROUP BY namelast, namefirst, cp.schoolid, schoolname
ORDER BY total_salary DESC
--player David Price earned the most. He made $81,851,296 (two salaries were repeated)
--s/o to the group for showing me the discrepency in the salaries 

--4.Fielding Table, group players (3) on position. OF = Outfield; SS,1B, 2B, 3B = Infield; P,C = Battery
--Number of putouts? 
SELECT SUM(PO) AS put_outs, 
CASE WHEN POS = 'OF' THEN 'Outfield'
  WHEN POS = 'SS' OR POS LIKE '%B' THEN 'Infield'
  ELSE 'Battery' END AS group_positions
FROM fielding
WHERE yearid = 2016
GROUP BY group_positions
ORDER BY put_outs DESC
--INFIELD: 58,934
--BATTERY: 41,424
--OUTFIELD: 29,560

--5. Find the average number of strikeouts per game by decade since 1920. Round 2 decimals.
SELECT SUM(G)/2 AS games, 
yearid/10*10 as decade, 
ROUND(SUM(CAST(so as numeric))/(SUM(G/2)), 2) as avg_SO, 
ROUND(SUM(CAST(hr as numeric))/(SUM(G/2)), 2) as avg_HR
FROM teams
WHERE yearid >= 1920 --Think there is still a problem where the years are only counting 1920 not 1920-29
GROUP BY decade
ORDER BY decade
-- TEAMS / divided by 2 HELP FROM PRESTON
--SO: postive relationship with decades where HR seems to be relatively uneffected by the varying decades

--6. Most success at stealing bases (2016) where success = percentage of stolen base attempts that succeed... at least 20
SELECT distinct namegiven, 
SUM(sb) as success_sb_2016, SUM(sb) + SUM(cs) as total_attempts,
ROUND(CAST(SUM(sb) as numeric)/(CAST(SUM(sb) as numeric) + CAST(SUM(cs) as numeric))*100,2) as percent_success_rate
FROM batting
JOIN people
USING (playerid) 
WHERE yearid = 2016 AND (sb + cs) >=20
GROUP BY namegiven, sb, cs
ORDER BY percent_success_rate DESC;
--Chris Scott, 91.30% success percentage

--7. 1970-2016, largest # wins (lost world series) 
SELECT yearid, name, SUM(w) as game_wins, WSWin as World_Series_Champs
FROM teams
WHERE WSWin IS NOT NULL AND WSWIN = 'N' AND yearid BETWEEN 1970 AND 2016
GROUP BY yearid, name, World_Series_Champs
ORDER BY game_wins DESC;
--2001, Seattle Mariners, 116 wins, not a world series champion

--smallest # wins (won world series)
SELECT yearid, name, SUM(w) as game_wins, WSWin as World_Series_Champs
FROM teams
WHERE WSWin IS NOT NULL AND WSWIN = 'Y' AND yearid BETWEEN 1970 AND 2016 AND YEARID !=1981
GROUP BY yearid, name, World_Series_Champs
ORDER BY game_wins;
--w/o problem 1981 year where los angeles dogers won the world series w/ 63 game wins
--2006, St. Louis Cardinals, 83 wins, world series champion

--7. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
--What percentage of the time?
WITH highest_wins_per_year AS (SELECT DISTINCT yearid, MAX(w) OVER(PARTITION BY teamid) as most_games_won, WSWin
                            FROM teams
                            WHERE WSWin IS NOT NULL AND WSWin = 'Y' AND yearid BETWEEN 1970 AND 2016
                            GROUP BY teamid, yearid, w, WSWin
                            ORDER BY yearid DESC)
SELECT DISTINCT yearid, most_games_won, WSWin as World_Series_Champs
FROM highest_wins_per_year
JOIN teams
USING (yearid)
WHERE WSWin IS NOT NULL AND yearid BETWEEN 1970 AND 2016
GROUP BY yearid, name, World_Series_Champs, most_games_won
ORDER BY yearid DESC;
