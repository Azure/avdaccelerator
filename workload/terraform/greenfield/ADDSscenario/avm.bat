@echo off
SETLOCAL

REM Set CONTAINER_RUNTIME to its current value if it's already set, or docker if it's not
IF DEFINED CONTAINER_RUNTIME (SET "CONTAINER_RUNTIME=%CONTAINER_RUNTIME%") ELSE (SET "CONTAINER_RUNTIME=docker")

REM Check if CONTAINER_RUNTIME is installed
WHERE /Q %CONTAINER_RUNTIME%
IF ERRORLEVEL 1 (
    echo Error: %CONTAINER_RUNTIME% is not installed. Please install %CONTAINER_RUNTIME% first.
    exit /b
)

REM Check if a make target is provided
IF "%~1"=="" (
    echo Error: Please provide a make target. See https://github.com/Azure/tfmod-scaffold/blob/main/avmmakefile for available targets.
    exit /b
)

REM Run the make target with CONTAINER_RUNTIME
%CONTAINER_RUNTIME% run --pull always --rm -v "%cd%":/src -w /src -e GITHUB_REPOSITORY -e GITHUB_REPOSITORY_OWNER mcr.microsoft.com/azterraform make %1

ENDLOCAL
