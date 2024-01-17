@echo off
rem 注意 :
rem 1.有中文的部分需用 "" 防止出現 "?" is not recognized as an internal or external command, operable program or batch file.
rem 2.路徑都要為 \ 否則系統不接受
rem 3.rem 為註解說明

rem 需手動配置調整(已調整為詢問方式) :
rem 1.FROM_CommitID 				git 起始CommitID
rem 2.TO_CommitID 					git 截止CommitID
rem 3.Final_Target_File_Address 	檔案存放位置

echo "程式啟動 ---------->"

echo "進度 =============== 0%%"

echo "config 設置開始 ----->"

echo "設置編碼開始 UTF-8 ---------->"
rem 設置編碼 UTF-8
chcp 65001
echo "設置編碼結束 UTF-8 <----------"

echo "啟用延遲擴張"
rem 啟用延遲擴張
setlocal enabledelayedexpansion

echo 請輸入 git 起始 CommitID 的前一天 (例如:8623a05f) 如果未輸入，直接停止程式
set /P FROM_CommitID=
if not defined FROM_CommitID goto :end
echo 你輸入的是: %FROM_CommitID%

echo 請輸入 git 截止 CommitID (例如:454f509d) 如果未輸入，直接停止程式
set /P TO_CommitID=
if not defined TO_CommitID goto :end
echo 你輸入的是: %TO_CommitID%

rem 建立預設目錄格式:yyyy_MM_dd_HHmmss
set year=%date:~3,4%
set month=%date:~8,2%
set day=%date:~11,2%
set hour=%time:~0,2%
set minute=%time:~3,2%
set second=%time:~6,2%
set yyyyMMddHHmmss=%year%_%month%_%day%_%hour%%minute%%second%

rem 存放檔案位置
rem 範例 : set Final_Target_File_Address="\\File-server\share\企業簡訊事業群\簡訊研發部\公用資料夾\【中心端調整】\20230526_測試用"
echo 請輸入存放檔案位置，如果未輸入，預設為專案根目錄
set /P Final_Target_File_Address=
if not defined Final_Target_File_Address (
    set Final_Target_File_Address=%yyyyMMddHHmmss%
)
echo 檔名存放在:%Final_Target_File_Address%

echo "進度 =============== 10%%"

rem target 檔案路徑對應位置
set Commit_File=commit_files.txt
set Target_File=result.txt
set Target_Repeat_File=repeat_result.txt

rem 轉換 commit 檔案路徑位置到 target 對應的檔案路徑位置
set target=WebContent\WEB-INF\classes
set target_test=target\test-classes

echo "config 設置結束 <-----"

echo "進度 =============== 20%%"

echo "開始建立 !Commit_File! ----->"
rem 取得符合日期範圍的 git commit 的檔案路徑存放至 !Commit_File!
if not exist !Commit_File! echo. > !Commit_File!
echo "建立完成 !Commit_File! <-----"

echo "開始取得 git commit 檔案路徑並存入 !Commit_File! ----->"
git diff -r --no-commit-id --name-only --text  %FROM_CommitID% %TO_CommitID%  > !Commit_File!
echo "git diff -r --no-commit-id --name-only --text"  %FROM_CommitID% %TO_CommitID%
echo "結束取得 git commit 檔案路徑已存入 !Commit_File! <-----"

echo "進度 =============== 40%%"

echo "讀取 !Commit_File! 開始 ----->"
echo "開始建立 !Target_File!  ----->"
rem 讀取 !Commit_File! 檔並尋找對應的 class 檔存入 !Target_File!
for /f "tokens=*" %%a in (!Commit_File!) do (
		set oldfile=%%a
		set file=!oldfile:/=\!
		set xml=""

		rem 有沒有 x 插在檔案類型
        rem echo 路徑: %%~dpa
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
				set java=!file:src=%target%!
				call set java=%%java:java=class%%
				rem echo Java: !file!
				rem echo class: !java!
				echo !java!>>"%Target_File%"
			)
		rem 在這裡執行相應的操作，處理資源文件
		) else if "!file:~-4!"==".xml" (
		    echo !file!| find "WebContent" >nul
		    if errorlevel 1 (
		        rem echo 無 WebContent 路徑: !file!
                set xml=!file:src=%target%!
                rem echo 替換 WebContent 路徑: !xml!
                echo !xml!>>"%Target_File%"
		    ) else (
		        rem echo 有 WebContent 路徑: !file!
                echo !file!>>"%Target_File%"
		    )
        rem 統一處裡未知 or .jsp，.properties，.dll，.MF，.js，.css，.gif，.png，.jpg，.bmp，.db，.jasper，.jrxml，.pdf，.csv，.txt，.exe，.zip，.xls
        ) else (
            echo "統一處裡類型 or 未知類型: !file!"
            echo !file! >>"%Target_File%"
        )
)
echo "建立完成 !Target_File!  <-----"
echo "讀取 !Commit_File! 結束 <-----"

echo "進度 =============== 60%%"

echo "讀取 !Target_File! 開始 ----->"
echo "開始建立 !Target_Repeat_File!  ----->"
rem 讀取 !Target_File! 檔並尋找缺少的 class 檔存入 !Target_Repeat_File!
for /f "tokens=*" %%a in (!Target_File!) do (
	set "_path=%%a"
	set "_is_class=!_path:~-6!"
	set "_file_name=%%~nxa"

    rem echo !_path!
	rem echo !_is_class!
	rem echo !_file_name!

	for %%b in ("%%~dpna*") do (
		set file_name=%%~nxb

        rem echo %%b
		rem echo !file_name!

		if /i "!_is_class!" == ".class" (
			set "_dir=%%~dpa"
			set "_dir=!_dir:%cd%\=!"
			if "!_file_name!" == "!file_name!" (
                rem  echo 相同 : _file_name: !_file_name!，file_name: !file_name!
                rem  echo !_dir!!file_name!
                echo !_dir!!file_name!>>"%Target_Repeat_File%"
			) else (
			    rem  echo 不相同 : _file_name: !_file_name!，file_name: !file_name!
			    echo !file_name!| find "$" >nul
			    if errorlevel 1 (
                    rem  echo 沒有$字符號
                ) else (
                    rem echo 有$字符號
                    rem echo !_dir!!file_name!
                    echo !_dir!!file_name!>>"%Target_Repeat_File%"
                )
			)
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
rem 讀取 !Target_Repeat_File! 檔並複製檔案至指定位置 !Final_Target_File_Address!
for /f "tokens=*" %%a in (!Target_Repeat_File!) do (
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

echo "進度 =============== 100%%"
:end

echo "關閉延遲擴張"
rem 關閉延遲擴張
endlocal

echo "程式結束 <----------"
rem 關閉腳本 : rem pause 
rem 暂停腳本 : pause
pause