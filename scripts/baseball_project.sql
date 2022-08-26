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
SELECT SUM(t.G)/2 AS games, p_sq.yearid/10*10 as decade, ROUND(p_sq.sum_so/(t.G/2), 2) as avg_SO, ROUND(p_sq.sum_hr/(t.G/2), 2) as avg_HR
FROM (SELECT p.yearid, p.playerid, SUM(SO) as sum_so, SUM(HR) as sum_hr
      FROM pitching as p
      WHERE p.yearid >=1920
      GROUP BY playerid, p.yearid) as p_sq
JOIN teams as t
USING (yearid)
GROUP BY decade, p_sq.sum_so, p_sq.sum_hr, t.g
ORDER BY decade

SELECT SUM(G)/2 AS games, yearid/10*10 as decade, ROUND(SUM(so)/(G/2), 2) as avg_SO, ROUND(SUM(hr)/(G/2), 2) as avg_HR
FROM teams
WHERE yearid >= 1920
GROUP BY decade, G
ORDER BY decade

SELECT g, yearid, teamid
FROM teams;

---- TEAMS / divided by 2 HELP FROM PRESTON
--HR: There is not much of a pattern, but the 1970s had the highest avg HR 


--6. Most success at stealing bases (2016) where success = percentage of stolen base attempts that succeed... at least 20
SELECT distinct playerid, SUM(sb)
FROM batting
GROUP BY playerid







