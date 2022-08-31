--1.What range of years for baseball games played does the provided database cover?
SELECT MIN(debut), MAX(finalgame)
FROM people
--Date Range: 1871-2017 (but it is the 2016 season)

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
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade
-- TEAMS / divided by 2 HELP FROM PRESTON
--SO: postive relationship with decades where HR seems to be relatively uneffected by the varying decades
--does the trend have to do with civil rights movement and letting all races play the sport? 
--because Jackie Robinson was the first african-american to play major baseball and his first game was in 1947

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
WHERE WSWIN = 'N' AND yearid BETWEEN 1970 AND 2016
GROUP BY yearid, name, World_Series_Champs
ORDER BY game_wins DESC;
--2001, Seattle Mariners, 116 wins, not a world series champion

--7.smallest # wins (won world series)
SELECT yearid, name, SUM(w) as game_wins, WSWin as World_Series_Champs
FROM teams
WHERE WSWIN = 'Y' AND yearid BETWEEN 1970 AND 2016 AND YEARID !=1981
GROUP BY yearid, name, World_Series_Champs
ORDER BY game_wins;
--w/o problem 1981 year where los angeles dogers won the world series w/ 63 game wins
--2006, St. Louis Cardinals, 83 wins, world series champion

--7. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
--What percentage of the time?
WITH CTE_N AS (SELECT COUNT(sub1.World_Series_win) as num_maxw_noWS
               FROM (SELECT t.yearid, t.w, t.wswin as World_Series_win
                     FROM teams as t
                     JOIN (SELECT yearid, MAX(w) as highest_games_won 
                           FROM teams 
                           GROUP BY yearid) AS subquery ON subquery.yearid = t.yearid AND subquery.highest_games_won = t.w
                           WHERE t.yearid BETWEEN 1970 AND 2016
                           ORDER BY t.yearid DESC) as sub1
                            WHERE sub1.World_Series_win = 'N'),
CTE_Y AS (SELECT COUNT(sub2.World_Series_win) as num_maxw_WSwin
               FROM (SELECT t.yearid, t.w, t.wswin as World_Series_win
                     FROM teams as t
                     JOIN (SELECT yearid, MAX(w) as highest_games_won 
                           FROM teams 
                           GROUP BY yearid) AS subquery ON subquery.yearid = t.yearid AND subquery.highest_games_won = t.w
                           WHERE t.yearid BETWEEN 1970 AND 2016
                           ORDER BY t.yearid DESC) as sub2
                           WHERE sub2.World_Series_win = 'Y')
SELECT (num_maxw_noWS-6) as num_maxw_noWS, num_maxw_WSwin, 
ROUND(((CAST(num_maxw_noWS as numeric)-6)/46)*100,2) AS percent_noWS,
ROUND((CAST(num_maxw_WSwin as numeric)/46)*100,2) AS percent_WSwin
FROM CTE_N              
CROSS JOIN CTE_Y
--2013,2007, 2006 2003,2002,1971 are all ties for max, 1994 is null, so total of 7 so 53-7 = 46
--ANSWER 7.c.a: max wins and no world series is more prevalent
--ANSWER 7.c.b: percentage no world series win and max games won = 73.91%
--              percentage world series win and max games won =26.09
--THIS QUESTION GETS A THUMBS DOWN FROM ME

--8. Teams & Parks with the Top 5 avg. attendence PER GAME in 2016. More than 10 games 
SELECT teams.name, park_name, SUM(games) as total_games, 
ROUND(SUM(CAST(homegames.attendance as numeric))/SUM(CAST(games as numeric)),2) as AVG_attendance
FROM homegames
JOIN parks
USING (park)
JOIN teams
ON teams.teamid = homegames.team AND teams.yearid = homegames.year
WHERE year = 2016 AND games > 10
GROUP BY teams.name, park_name
ORDER BY avg_attendance DESC
LIMIT 5
--Top 5 ^
--Bottom 5 
SELECT teams.name, park_name, SUM(games) as total_games, 
ROUND(SUM(CAST(homegames.attendance as numeric))/SUM(CAST(games as numeric)),2) as AVG_attendance
FROM homegames
JOIN parks
USING (park)
JOIN teams
ON teams.teamid = homegames.team AND teams.yearid = homegames.year
WHERE year = 2016 AND games > 10
GROUP BY teams.name, park_name
ORDER BY avg_attendance
LIMIT 5
--I must have done something wrong.... this seemed too straight forward

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
--Give their full name and the teams that they were managing when they won the award.
--THE BELOW IS MY FIRST WHERE I MANUALLY FOUND THE RIGHT PEOPLE
-- SELECT am.playerid, p.namefirst, p.namelast, am.awardid, am.lgid, am.yearid, t.name
-- FROM awardsmanagers am
-- JOIN awardsmanagers am2
-- USING (playerid)
-- JOIN people p
-- USING (playerid)
-- JOIN managers m
-- USING(yearid,playerid)
-- JOIN teams t
-- ON t.teamid = m.teamid
-- WHERE awardid = 'TSN Manager of the Year' AND am.lgid IN ('AL','NL')
-- AND playerid IN ('johnsda02', 'leylaji99')
-- GROUP BY am.playerid,  p.namefirst, p.namelast, am.awardid, am.lgid, am.yearid, t.name
-- ORDER BY am.playerid

SELECT am.playerid, CONCAT(p.namefirst,' ', p.namelast) as full_name, am2.awardid, am.lgid, am.yearid, am2.lgid, am2.yearid, t.name
FROM awardsmanagers am
JOIN awardsmanagers am2
USING (playerid)
JOIN people p
USING (playerid)
JOIN managers m
ON am.yearid = m.yearid AND am.playerid = m.playerid
JOIN teams t
ON t.teamid = m.teamid
WHERE am.awardid = 'TSN Manager of the Year' AND am2.awardid = 'TSN Manager of the Year' 
AND am.lgid ='NL' AND am2.lgid = 'AL'
GROUP BY am.playerid, full_name, am2.awardid, am.lgid, am2.lgid, am.yearid, am2.yearid, t.name
ORDER BY am.playerid