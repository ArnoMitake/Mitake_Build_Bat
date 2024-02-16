@echo off
rem "此版本為最終版本(未來可能只調整此版本)"
rem "目標:"
rem "1.可指定專案類型 (1.Web 2.Java)"
rem "2.可指定 git 查詢類型 (1.日期查詢 2.CommitID查詢)"
rem "3.如果 git 用日期查詢，動態時間格式"
rem     "* 時間區間格式: yyyy-MM-dd -> 自動帶入 THH:mm:ssZ"
rem     "* 時間區間格式: yyyy-MM-ddTHH:mm:ssZ -> 不做任何處理"

rem "注意 :"
rem "1.有中文的部分需用 "" 防止出現 "?" is not recognized as an internal or external command, operable program or batch file."
rem "2.路徑都要為 \ 否則系統不接受"
rem "3.rem 為註解說明"

rem "需手動配置調整(已調整為詢問方式) :"
rem "1.FROM_CommitID 				git 起始CommitID"
rem "2.TO_CommitID 					git 截止CommitID"
rem "3.Final_Target_File_Address 	檔案存放位置"

echo "程式啟動 ---------->"

echo "進度 =============== 0%%"

echo "config 設置開始 ----->"

echo "設置編碼開始 UTF-8 ---------->"
rem "設置編碼 UTF-8"
chcp 65001
echo "設置編碼結束 UTF-8 <----------"

echo "啟用延遲擴張"
rem "啟用延遲擴張"
setlocal enabledelayedexpansion

rem "專案類型:ProjectType 1.Web 2.Java"
echo "請選擇專案類型，如果未輸入，直接停止程式" &echo\"1.Web"&echo\"2.Java"
set /P ProjectType=
if "!ProjectType!"=="1" (
    echo "專案類型為: Web"
    echo "--------------> 執行前須注意:Web 版的 Java 需手動 build 過在執行此程式 <--------------"
    echo "--------------> 執行前須注意:Web 版的 Java 需手動 build 過在執行此程式 <--------------"
    echo "--------------> 執行前須注意:Web 版的 Java 需手動 build 過在執行此程式 <--------------"
    echo "--------------> 執行前須注意:Web 版的 Java 需手動 build 過在執行此程式 <--------------"
    echo "--------------> 執行前須注意:Web 版的 Java 需手動 build 過在執行此程式 <--------------"
    rem timeout /t 5 /nobreak > nul
) else if "!ProjectType!"=="2" (
    echo "專案類型為: Java"
    echo "執行 Maven Package -----> 開始"
    call mvn package
    echo "執行 Maven Package -----> 結束"
) else if not defined ProjectType goto :end

rem "git查詢方式:GitQueryType 1.日期查詢 2.CommitID查詢"
echo "請選擇 git 查詢方式，如果未輸入，直接停止程式" &echo\"1.日期查詢"&echo\"2.CommitID查詢"
set /P GitQueryType=
if "!GitQueryType!"=="1" (
    echo "git 查詢方式為: 日期查詢"
) else if "!GitQueryType!"=="2" (
    echo "git 查詢方式為: CommitID查詢"
) else if not defined GitQueryType goto :end

rem "起始git查詢參數設定"
if "!GitQueryType!"=="1" (
    rem "取得起始日期"
    echo "請輸入 git 起始日期，如果未輸入，直接停止程式  (例如:yyyyMMdd or yyyyMMddTHHmmssZ)"
    set /P FROM_DATE=
    if not defined FROM_DATE goto :end
    rem "檢查日期格式"

     echo !FROM_DATE!| find "T" >nul
        if errorlevel 1 (
            rem echo "yyyyMMdd:!FROM_DATE!"
            set FROM_DATE=!FROM_DATE!T000000Z
        ) else (
            rem echo "yyyyMMddTHHmmssZ:!FROM_DATE!"
        )
    echo "起始日期為: !FROM_DATE!"
    rem "用起始日期取得 Hash Commit"
    for /f "tokens=*" %%a in ('git log --before="!FROM_DATE!" --format^=%%H -n 1') do (
        set FROM_CommitID=%%a
    )
    echo "commit 的 hash 為：!FROM_CommitID!"
) else if "!GitQueryType!"=="2" (
    rem "取得起始CommitID"
    echo "請輸入 git 起始 CommitID 的前一天(當天有可能會抓不到)，如果未輸入，直接停止程式 (例如:8623a05f，git tools 不同顯示的會不一樣)"
    set /P FROM_CommitID=
    if not defined FROM_CommitID goto :end
    echo "你輸入的是: !FROM_CommitID!"
)

rem "日期配置"
set year=%date:~3,4%
set month=%date:~8,2%
set day=%date:~11,2%
set hour=%time:~0,2%
set minute=%time:~3,2%
set second=%time:~6,2%
rem "建立預設目錄格式:yyyy_MM_dd_HHmmss"
set yyyyMMddHHmmss=%year%_%month%_%day%_%hour%%minute%%second%

rem "截止git查詢參數設定"
if "!GitQueryType!"=="1" (
    rem "取得截止日期"
    echo "請輸入 git 截止日期，如果未輸入，預設為最新日期 (例如:yyyy-MM-dd or yyyy-MM-ddTHH:mm:ssZ)"
    set /P TO_DATE=
    if not defined TO_DATE (
        set TO_DATE=%year%-%month%-%day%
    )
    rem "檢查日期格式"
    echo !TO_DATE!| find ":" >nul
        if errorlevel 1 (
            rem echo "yyyy-MM-dd:!TO_DATE!"
            set TO_DATE=!TO_DATE!T00:00:00Z
        ) else (
            rem echo "yyyy-MM-ddTHH:mm:ssZ:!TO_DATE!"
        )
    echo "截止日期為: !TO_DATE!"
    rem "用截止日期取得 Hash Commit"
    for /f "tokens=*" %%a in ('git log --before=!TO_DATE! --format^=%%H -n 1') do (
        set TO_CommitID=%%a
    )
    echo "commit 的 hash 為：!TO_CommitID!"
) else if "!GitQueryType!"=="2" (
    rem "取得截止CommitID"
    echo "請輸入 git 截止 CommitID，如果未輸入，直接停止程式 (例如:8623a05f，git tools 不同顯示的會不一樣)"
    set /P TO_CommitID=
    if not defined TO_CommitID goto :end
    echo "你輸入的是: !TO_CommitID!"
)

rem "存放檔案位置"
rem "範例 : set Final_Target_File_Address="\\File-server\share\企業簡訊事業群\簡訊研發部\公用資料夾\【中心端調整】\20230526_測試用"
echo "請輸入存放檔案位置，如果未輸入，預設為專案根目錄"
set /P Final_Target_File_Address=
if not defined Final_Target_File_Address (
    set Final_Target_File_Address=!yyyyMMddHHmmss!
)
echo "檔名存放在:!Final_Target_File_Address!"

rem "target 檔案路徑對應位置"
set Commit_File=commit_files.txt
set Target_File=result.txt
set Target_Repeat_File=repeat_result.txt

echo "進度 =============== 10%%"

rem "區分專案類型 ProjectType 1.Web 2.Java (整段處裡邏輯分開寫)"
rem "考量因素:"
rem "1.debug 較方便"
rem "2.專案構造不同，未來很難改動"
if "!ProjectType!"=="1" goto :Web
if "!ProjectType!"=="2" goto :Java

echo "ProjectType 不正確:!ProjectType!"
goto :end

:Web
rem "轉換 commit 檔案路徑位置到 target 對應的檔案路徑位置"
echo "請輸入 build 完成後 classes 的位置 請選擇" &echo\"1.build\classes" &echo\"2.WebContent\WEB-INF\classes" &echo\"以上都無，可將路徑位置直接貼上(預設為2)"
set /P target=
if not defined target (
    set target="2"
)
if "!target!"=="1" (
    call set target=build\classes
) else if "!target!"=="2" (
    call set target=WebContent\WEB-INF\classes
)
echo "target 路徑設置為:!target!"

rem "todo 等有遇到 test 專案再調整"
set target_test=target\test-classes

echo "config 設置結束 <-----"

echo "進度 =============== 20%%"

echo "開始建立 !Commit_File! ----->"
rem "取得符合日期範圍的 git commit 的檔案路徑存放至 !Commit_File!"
if not exist !Commit_File! echo. > !Commit_File!
echo "建立完成 !Commit_File! <-----"

echo "開始取得 git commit 檔案路徑並存入 !Commit_File! ----->"
git diff -r --no-commit-id --name-only --text  !FROM_CommitID! !TO_CommitID!  > !Commit_File!
echo "git diff -r --no-commit-id --name-only --text"  !FROM_CommitID! !TO_CommitID!
echo "結束取得 git commit 檔案路徑已存入 !Commit_File! <-----"

echo "進度 =============== 40%%"

echo "讀取 !Commit_File! 開始 ----->"
echo "開始建立 !Target_File!  ----->"
rem "讀取 !Commit_File! 檔並尋找對應的 class 檔存入 !Target_File!"
for /f "tokens=*" %%a in (!Commit_File!) do (
		set oldfile=%%a
		set file=!oldfile:/=\!
		set xml=""

		rem "有沒有 x 插在檔案類型"
        rem echo "路徑: %%~dpa"
        rem echo "檔案名稱: %%~nxa"

		rem "在這裡執行相應的操作，處理 Java 文件"
		if "!file:~-5!"==".java" (
			rem "在這裡執行相應的操作，處理 test 文件"
			if "!file:\test\=!" neq "!file!" (
				set test=!file:src\test\java=%target_test%!
				call set test=%%test:java=class%%
				rem echo "!test!"
				echo !test!>>"!Target_File!"
			) else (
				set java=!file:src=WebContent\WEB-INF\classes!
				call set java=%%java:java=class%%
				rem echo "Java: !file!"
				rem echo "class: !java!"
				echo !java!>>"!Target_File!"
			)
		rem "在這裡執行相應的操作，處理資源文件"
		) else if "!file:~-4!"==".xml" (
		    echo !file!| find "WebContent" >nul
		    if errorlevel 1 (
		        rem echo "無 WebContent 路徑: !file!"
                set xml=!file:src=WebContent\WEB-INF\classes!
                rem echo "替換 WebContent 路徑: !xml!"
                echo !xml!>>"!Target_File!"
		    ) else (
		        rem echo "有 WebContent 路徑: !file!"
                echo !file!>>"!Target_File!"
		    )
        rem "統一處裡未知 or .jsp，.properties，.dll，.MF，.js，.css，.gif，.png，.jpg，.bmp，.db，.jasper，.jrxml，.pdf，.csv，.txt，.exe，.zip，.xls"
        ) else (
            echo "統一處裡類型 or 未知類型: !file!"
            echo !file! >>"!Target_File!"
        )
)
echo "建立完成 !Target_File!  <-----"
echo "讀取 !Commit_File! 結束 <-----"

echo "進度 =============== 60%%"

echo "讀取 !Target_File! 開始 ----->"
echo "開始建立 !Target_Repeat_File!  ----->"
rem "讀取 !Target_File! 檔並尋找缺少的 class 檔存入 !Target_Repeat_File!"
for /f "tokens=*" %%a in (!Target_File!) do (
	set "_path=%%a"
	set "_is_class=!_path:~-6!"
	set "_file_name=%%~nxa"

    rem echo "!_path!"
	rem echo "!_is_class!"
	rem echo "!_file_name!"

	for %%b in ("%%~dpna*") do (
		set file_name=%%~nxb

        rem echo "%%b"
		rem echo "!file_name!"

		if /i "!_is_class!" == ".class" (
			set "_dir=%%~dpa"
			set "_dir=!_dir:%cd%\=!"
			if "!_file_name!" == "!file_name!" (
                rem  echo "相同 : _file_name: !_file_name!，file_name: !file_name!"
                rem  echo "!_dir!!file_name!"
                echo !_dir!!file_name!>>"!Target_Repeat_File!"
			) else (
			    rem  echo "不相同 : _file_name: !_file_name!，file_name: !file_name!"
			    echo !file_name!| find "$" >nul
			    if errorlevel 1 (
                    rem  echo "沒有$字符號"
                ) else (
                    rem echo "有$字符號"
                    rem echo "!_dir!!file_name!"
                    echo !_dir!!file_name!>>"!Target_Repeat_File!"
                )
			)
		)
	)
	if /i not "!_is_class!" == ".class" (
		rem echo "這是外層: %%a"
		echo %%a>>"!Target_Repeat_File!"
	)
)
echo "建立完成 !Target_Repeat_File!  <-----"
echo "讀取 !Target_File! 結束 <-----"

echo "進度 =============== 80%%"

echo "建立資料夾開始 -----> !Final_Target_File_Address!"
if not exist "!Final_Target_File_Address!" mkdir "!Final_Target_File_Address!"
echo "建立資料夾結束 <----- !Final_Target_File_Address!"

echo "讀取 !Target_Repeat_File! 開始 ----->"
echo "複製檔案中..."
rem "讀取 !Target_Repeat_File! 檔並複製檔案至指定位置 !Final_Target_File_Address!"
for /f "tokens=*" %%a in (!Target_Repeat_File!) do (
	mkdir "!Final_Target_File_Address!\%%a"
	rmdir /s /q "!Final_Target_File_Address!\%%a"
	copy  "%%a" "!Final_Target_File_Address!\%%a" > nul
)
echo "複製結束."
echo "讀取 !Target_Repeat_File! 結束 <-----"

echo "刪除檔案 ----->"  !Commit_File! , !Target_File! , !Target_Repeat_File!
rem "清理暫存檔案"
del !Commit_File!
del !Target_File!
del !Target_Repeat_File!

echo "進度 =============== 100%%"
goto :end

:Java
rem "轉換 commit 檔案路徑位置到 target 對應的檔案路徑位置"
set target=target\classes
set target_test=target\test-classes
echo "config 設置結束 <-----"

echo "進度 =============== 20%%"

echo "開始建立 !Commit_File! ----->"
rem "取得符合日期範圍的 git commit 的檔案路徑存放至 Commit_File"
echo "git diff -r --no-commit-id --name-only --text"  !FROM_CommitID! !TO_CommitID!
if !FROM_CommitID!==!TO_CommitID! (
    echo ">>>>>>>>>警告提示:起始 CommitID 與 截止 CommitId 相同，請將起始 CommitID 提前至前一個 CommitID"
    goto :end
)
if not exist commit_files.txt echo. > !Commit_File!
echo "建立完成 !Commit_File! <-----"
echo "開始取得 git commit 檔案路徑並存入 !Commit_File! ----->"
git diff -r --no-commit-id --name-only --text  !FROM_CommitID! !TO_CommitID!  > !Commit_File!
echo "結束取得 git commit 檔案路徑已存入 !Commit_File! <-----"

echo "進度 =============== 40%%"

echo "讀取 !Commit_File! 開始 ----->"
echo "開始建立 !Target_File!  ----->"
rem "讀取 commit_files.txt 檔並尋找對應的 class 檔存入 result.txt"
for /f "tokens=*" %%a in (!Commit_File!) do (
		set oldfile=%%a
		set file=!oldfile:/=\!
		set xml=""

	rem echo "路徑: %%~dpa"
	rem "有沒有 x 插在檔案類型"
	rem echo "檔案名稱: %%~nxa"

		rem "在這裡執行相應的操作，處理 Java 文件"
		if "!file:~-5!"==".java" (
			rem "在這裡執行相應的操作，處理 test 文件"
			if "!file:\test\=!" neq "!file!" (
				set test=!file:src\test\java=%target_test%!
				call set test=%%test:java=class%%
				rem echo "!test!"
				echo !test!>>"!Target_File!"
			) else (
				set java=!file:src\main\java=%target%!
				call set java=%%java:java=class%%
				echo "Java: !file!"
				echo "class: !java!"
				echo !java!>>"!Target_File!"
			)
		rem "在這裡執行相應的操作，處理資源文件"
		) else if "!file:~-4!"==".xml" (
			rem "在這裡執行相應的操作，處理 pom.xml"
			if "!file:~-7!"=="pom.xml" (
				rem echo "pom: !file!"
				echo !file!>>"!Target_File!"
			) else (
				echo xml: !file!
                for /f "tokens=1,2,3 delims=\ " %%a in ("!file!") do (
                    call set xml=!file:%%a\%%b\%%c=%target%!
                )
				echo "Nxml: !xml!"
				echo !xml!>>"!Target_File!"
			)
		rem "在這裡執行相應的操作，處理 app.properties"
		) else if "!file:~-11!"==".properties" (
			rem echo "properties: !file!"
			echo !file! >>"!Target_File!"
		rem "在這裡執行相應的操作，處理 sqljdbc_auth.dll"
		) else if "!file:~-4!"==".dll" (
			rem echo "dll: !file!"
			echo !file!>>"!Target_File!"
        rem "在這裡執行相應的操作，處理未知類型的文件"
		) else (
			echo error: !file!
		)
)
echo "建立完成 !Target_File!  <-----"
echo "讀取 !Commit_File! 結束 <-----"

echo "進度 =============== 60%%"

echo "讀取 !Target_File! 開始 ----->"
echo "開始建立 !Target_Repeat_File!  ----->"
rem "讀取 result.txt 檔並尋找缺少的 class 檔存入 repeat_result.txt"
for /f "tokens=*" %%a in (result.txt) do (
	set "_path=%%a"
	set "_is_class=!_path:~-6!"
	set "_file_name=%%~nxa"

	for %%b in ("%%~dpna*") do (
		set file_name=%%~nxb

		if /i "!_is_class!" == ".class" (

			set "_dir=%%~dpa"
			set "_dir=!_dir:%cd%\=!"

			if "!_file_name!" == "!file_name!" (
                rem echo "相同 : _file_name: !_file_name!，file_name: !file_name!"
                rem echo "!_dir!!file_name!"
                echo !_dir!!file_name!>>"!Target_Repeat_File!"
			) else (
			    rem echo "不相同 : _file_name: !_file_name!，file_name: !file_name!"
			    echo !file_name!| find "$" >nul
			    if errorlevel 1 (
                    rem echo "沒有$字符號"
                ) else (
                    rem echo "有$字符號"
                    rem echo "!_dir!!file_name!"
                    echo !_dir!!file_name!>>"!Target_Repeat_File!"
                )
			)
		)
	)

	if /i not "!_is_class!" == ".class" (
		rem echo "這是外層: %%a"
		echo %%a>>"!Target_Repeat_File!"
	)
)
echo "建立完成 !Target_Repeat_File!  <-----"
echo "讀取 !Target_File! 結束 <-----"

echo "進度 =============== 80%%"

echo "建立資料夾開始 -----> !Final_Target_File_Address!"
if not exist "!Final_Target_File_Address!" mkdir "!Final_Target_File_Address!"
echo "建立資料夾結束 <----- !Final_Target_File_Address!"


echo "讀取 !Target_Repeat_File! 開始 ----->"
echo "複製檔案中..."
rem "讀取 repeat_result.txt 檔並複製檔案至指定位置 Final_Target_File_Address"
for /f "tokens=*" %%a in (repeat_result.txt) do (

	mkdir "!Final_Target_File_Address!\%%a"
	rmdir /s /q "!Final_Target_File_Address!\%%a"
	copy  "%%a" "!Final_Target_File_Address!\%%a" > nul

)
echo "複製結束."
echo "讀取 !Target_Repeat_File! 結束 <-----"

echo "刪除檔案 ----->"  !Commit_File! , !Target_File! , !Target_Repeat_File!
rem "清理暫存檔案"
del !Commit_File!
del !Target_File!
del !Target_Repeat_File!

endlocal

echo "進度 =============== 100%%"

:end
echo "關閉延遲擴張"
rem "關閉延遲擴張"
endlocal

echo "程式結束 <----------"
rem "關閉腳本 : rem pause"
rem "暂停腳本 : pause"
pause
