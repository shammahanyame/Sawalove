@echo off
REM SawaLove backend test runner (Windows).
REM Boots an ISOLATED throwaway MySQL instance (port 3307) + PHP dev server,
REM imports schema.sql, then runs the full integration suite and the
REM brute-force / rate-limit enforcement test.
REM
REM Prerequisites:
REM   - MySQL 8 server binaries (set MYSQL_BIN below if not on the default path)
REM   - PHP 8.1+ CLI with pdo_mysql and curl ("php" on PATH)
REM
REM Usage:  tests\run_all.bat

setlocal enabledelayedexpansion

set "MYSQL_BIN=C:\Program Files\MySQL\MySQL Server 8.0\bin"
set "PHP=php"
set "BASE_DIR=%~dp0.."
set "TMPDATA=%TEMP%\sawalove-ci-mysql"
set "PORT=3307"

echo ==[1/5] Initializing throwaway MySQL data directory==
if exist "%TMPDATA%" rmdir /s /q "%TMPDATA%"
mkdir "%TMPDATA%"
"%MYSQL_BIN%\mysqld.exe" --no-defaults --initialize-insecure --datadir="%TMPDATA%" --basedir="%MYSQL_BIN%" || goto :fail

echo ==[2/5] Starting MySQL on port %PORT%==
start /b "" "%MYSQL_BIN%\mysqld.exe" --no-defaults --datadir="%TMPDATA%" --port=%PORT% --bind-address=127.0.0.1 --console > "%TEMP%\sawalove-ci-mysql.log" 2>&1
timeout /t 8 /nobreak >nul
"%MYSQL_BIN%\mysql.exe" -h 127.0.0.1 -P %PORT% -u root -e "select 1;" || goto :fail

echo ==[3/5] Creating database and importing schema==
"%MYSQL_BIN%\mysql.exe" -h 127.0.0.1 -P %PORT% -u root -e "create database sawalove_test character set utf8mb4 collate utf8mb4_unicode_ci; create user 'sawalove'@'%%' identified by 'testpass123'; grant all privileges on sawalove_test.* to 'sawalove'@'%%'; flush privileges;" || goto :fail
"%MYSQL_BIN%\mysql.exe" -h 127.0.0.1 -P %PORT% -u root sawalove_test < "%BASE_DIR%\schema.sql" || goto :fail

echo ==[4/5] Starting PHP API test server==
set "APP_ENV=local"
set "APP_KEY=test-key"
set "OTP_DEBUG_RESPONSE=true"
set "AUTH_RATE_LIMIT_MAX=1000"
set "DB_DSN=mysql:host=127.0.0.1;port=%PORT%;dbname=sawalove_test"
set "DB_USER=sawalove"
set "DB_PASSWORD=testpass123"
start /b "" %PHP% -S 127.0.0.1:8110 -t "%BASE_DIR%\public" "%BASE_DIR%\public\index.php"
timeout /t 2 /nobreak >nul

echo ==[5/5] Running integration suite==
%PHP% -d error_reporting="E_ALL & ~E_DEPRECATED" "%BASE_DIR%\tests\run_api_tests.php"
if errorlevel 1 goto :fail

echo.
echo == Running rate-limit enforcement test (fresh server, production defaults)==
for /f "tokens=5" %%p in ('netstat -ano ^| findstr :8111 ^| findstr LISTENING') do taskkill /f /pid %%p >nul 2>&1
set "AUTH_RATE_LIMIT_MAX="
start /b "" %PHP% -S 127.0.0.1:8111 -t "%BASE_DIR%\public" "%BASE_DIR%\public\index.php"
timeout /t 2 /nobreak >nul
%PHP% -d error_reporting="E_ALL & ~E_DEPRECATED" "%BASE_DIR%\tests\run_rate_limit_test.php" http://127.0.0.1:8111
if errorlevel 1 goto :fail

echo.
echo ALL BACKEND TESTS PASSED
goto :cleanup

:fail
echo.
echo TEST RUN FAILED
goto :cleanup

:cleanup
for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":8110 :8111 %PORT%" ^| findstr LISTENING') do taskkill /f /pid %%p >nul 2>&1
taskkill /f /im mysqld.exe /fi "WINDOWTITLE eq sawalove*" >nul 2>&1
endlocal
exit /b 0
