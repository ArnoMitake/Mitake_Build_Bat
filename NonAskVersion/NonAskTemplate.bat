@echo off

echo "設置編碼開始 UTF-8 ---------->"
rem 設置編碼 UTF-8
chcp 65001
echo "設置編碼結束 UTF-8 <----------"

rem 注意 : 
rem 1.有中文的部分需用 "" 防止出現 "?" is not recognized as an internal or external command, operable program or batch file.
rem 2.路徑都要為 \ 否則系統不接受

rem 需手動配置調整 :
rem 1.FROM_DATE 					git 起始日期
rem 2.TO_DATE 						git 至今日期
rem 3.Final_Target_File_Address 	檔案存放位置
rem git 起始日期 格式: yyyy-MM-dd
set FROM_DATE=2023-06-01
rem git 至今日期 格式: yyyy-MM-dd
set TO_DATE=2023-06-02
rem 存放檔案位置
rem 範例 : set Final_Target_File_Address="\\File-server\share\企業簡訊事業群\簡訊研發部\公用資料夾\【中心端調整】\20230526_測試用"
set Final_Target_File_Address="20230526_測試用"

echo "執行 Maven Package -----> 開始"

call mvn package

echo "執行 Maven Package -----> 結束"

echo "程式啟動 ---------->"

echo "進度 =============== 0%%"

echo "config 設置開始 ----->"

rem 啟用延遲擴張 
setlocal enabledelayedexpansion

rem git 起始日期 格式: yyyy-MM-dd
call set FROM_DATE="%FROM_DATE%T00:00:00Z"

rem git 至今日期 格式: yyyy-MM-dd
call set TO_DATE="%TO_DATE%T23:59:59Z"


echo "進度 =============== 10%%"

rem target 檔案路徑對應位置
set Commit_File=commit_files.txt
set Target_File=result.txt
set Target_Repeat_File=repeat_result.txt

rem 轉換 commit 檔案路徑位置到 target 對應的檔案路徑位置
set target=target\classes
set target_test=target\test-classes

echo "config 設置結束 <-----"

echo "進度 =============== 20%%"

echo "開始建立 !Commit_File! ----->"
rem 取得符合日期範圍的 git commit 的檔案路徑存放至 Commit_File
if not exist commit_files.txt echo. > !Commit_File!
echo "建立完成 !Commit_File! <-----"

echo "開始取得 git commit 檔案路徑並存入 !Commit_File! ----->"
git log --pretty=format: --name-only --after=%FROM_DATE% --before=%TO_DATE% | sort /unique > !Commit_File!
echo "結束取得 git commit 檔案路徑已存入 !Commit_File! <-----"

echo "進度 =============== 40%%"

echo "讀取 !Commit_File! 開始 ----->"
echo "開始建立 !Target_File!  ----->"
rem 讀取 commit_files.txt 檔並尋找對應的 class 檔存入 result.txt
for /f "tokens=*" %%a in (!Commit_File!) do (	
		set oldfile=%%a
		set file=!oldfile:/=\!
		set xml=""
		
	rem echo 路徑: %%~dpa
	rem 有沒有 x 插在檔案類型
	rem echo 檔案名稱: %%~nxa 
		
		rem 在這裡執行相應的操作，處理 Java 文件
		if "!file:~-5!"==".java" (
			rem 在這裡執行相應的操作，處理 test 文件
			if "!file:\test\=!" neq "!file!" (
				set test=!file:src\test\java=%target_test%!
				call set test=%%test:java=class%%
				rem echo !test!
				echo !test!>>"%Target_File%"
			) else (				
				set java=!file:src\main\java=%target%!
				call set java=%%java:java=class%%
				rem echo Java: !file! 
				rem echo class: !java!
				echo !java!>>"%Target_File%"
			)
		rem 在這裡執行相應的操作，處理資源文件
		) else if "!file:~-4!"==".xml" (
			rem 在這裡執行相應的操作，處理 pom.xml
			if "!file:~-7!"=="pom.xml" (
				rem echo pom: !file!
				echo !file!>>"%Target_File%"
			) else (
				call set xml=!file:src\main\resources=%target%!
				rem echo xml: !file!
				rem echo Nxml: !xml!
				echo !xml!>>"%Target_File%"
			)
		rem 在這裡執行相應的操作，處理 app.properties
		) else if "!file:~-11!"==".properties" (
			rem echo properties: !file! 
			echo !file! >>"%Target_File%"
		rem 在這裡執行相應的操作，處理 sqljdbc_auth.dll
		) else if "!file:~-4!"==".dll" (
			rem echo dll: !file! 
			echo !file!>>"%Target_File%"
        rem 在這裡執行相應的操作，處理未知類型的文件
		) else (
			echo error: !file!        
		)		
)
echo "建立完成 !Target_File!  <-----"
echo "讀取 !Commit_File! 結束 <-----"
	 
echo "進度 =============== 60%%"
	 
echo "讀取 !Target_File! 開始 ----->"
echo "開始建立 !Target_Repeat_File!  ----->"
rem 讀取 result.txt 檔並尋找缺少的 class 檔存入 repeat_result.txt
for /f "tokens=*" %%a in (result.txt) do (
	set "_path=%%a"
	set "_is_class=!_path:~-6!"
	
	for %%b in ("%%~dpna*") do (
		set file_name=%%~nxb
		if /i "!_is_class!" == ".class" (
			set "_dir=%%~dpa"
			set "_dir=!_dir:%cd%\=!"
			rem echo !_dir!!file_name!
			echo !_dir!!file_name!>>"%Target_Repeat_File%"
		)
	)
	
	if /i not "!_is_class!" == ".class" (
		rem echo 這是外層: %%a
		echo %%a>>"%Target_Repeat_File%"
	) 
)
echo "建立完成 !Target_Repeat_File!  <-----"
echo "讀取 !Target_File! 結束 <-----"

echo "進度 =============== 80%%"

echo "建立資料夾開始 -----> !Final_Target_File_Address!"
if not exist "%Final_Target_File_Address%" mkdir "%Final_Target_File_Address%"
echo "建立資料夾結束 <----- !Final_Target_File_Address!"


echo "讀取 !Target_Repeat_File! 開始 ----->"
echo "複製檔案中..."
rem 讀取 repeat_result.txt 檔並複製檔案至指定位置 Final_Target_File_Address
for /f "tokens=*" %%a in (repeat_result.txt) do (
	
	mkdir "%Final_Target_File_Address%\%%a"
	rmdir /s /q "%Final_Target_File_Address%\%%a"
	copy  "%%a" "%Final_Target_File_Address%\%%a" > nul

)
echo "複製結束."
echo "讀取 !Target_Repeat_File! 結束 <-----"

echo "刪除檔案 ----->"  !Commit_File! , !Target_File! , !Target_Repeat_File!
rem 清理暫存檔案
del !Commit_File!
del !Target_File!
del !Target_Repeat_File!

endlocal

echo "進度 =============== 100%%"

echo "程式結束 <----------"
rem 關閉腳本 : rem pause 
rem 暂停腳本 : pause
pause