@echo off 
setlocal enabledelayedexpansion

rem git 起始日期 格式: yyyy-MM-dd
set FROM_DATE=2023-04-26
rem git 至今日期 格式: yyyy-MM-dd
set TO_DATE=2023-06-02
rem 檔名
set name=checkmarx


call set FROM_DATE="%FROM_DATE%T00:00:00Z"
call set TO_DATE="%TO_DATE%T23:59:59Z"

git log --pretty=format: --name-only --after=%FROM_DATE% --before=%TO_DATE% | sort /unique > !name!.txt

mkdir !name!
for /f "tokens=*" %%a in (!name!.txt) do (	
	set file=%%a
	set newFile=!file:/=\!
	copy !newFile! !name!
)

powershell -noprofile -command "Add-Type -A 'System.IO.Compression.FileSystem'; [System.IO.Compression.ZipFile]::CreateFromDirectory('!name!', '!name!.zip')"

del !name!.txt
rd /s /q !name!