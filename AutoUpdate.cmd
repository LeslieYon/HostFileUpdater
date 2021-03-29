######脚本由RPK爱的温度开发#######
######BrightMbsh@Gmail.com########
###########2015-10-05#############
######转载或修改请保留此信息######
cls&@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
cd /d "%~dp0"
if not exist Source msg "%username%" /time:10 抱歉，暂无可用的源。&exit
choice /c Cl /n /t 3 /d l /m "按下字母C手动换源……"&cls
set Choice=%errorlevel%
if "%Choice%"=="1" (goto Custom) else goto Auto
:Custom
set ServerID=0&echo,Loading…
for /f "usebackq eol=# delims=; tokens=1,2,3,4*" %%a in ("%~dp0Source") do (
	set /a ServerID+=1
	set Server_!ServerID!_Dpath=%%a
	set Server_!ServerID!_Npath=%%b
	set Server_!ServerID!_Name=%%c
)
:CH_loop
cls&echo,以下是所有的源信息：&echo,= = = = = =&echo, 编号   名称	地址
for /l %%a in (1,1,%ServerID%) do (
call echo,  %%a  !Server_%%a_Name!	!Server_%%a_Dpath!
)
set UserCh=
echo,= = = = = =&echo,&set /p UserCh=直接输入源编号进行更新：
if not defined UserCh goto CH_loop
if defined Server_%UserCh%_Name (
	echo,Starting !Server_%UserCh%_Name!……
	call :UpdataHosts "!Server_%UserCh%_Dpath!" "%~dp0!Server_%UserCh%_Npath!"
	set return=false
)
goto CH_loop
:Auto
for /f "usebackq eol=# delims=; tokens=1,2,3,4*" %%a in ("%~dp0Source") do (
	echo,&echo,尝试链接源%%c……
	call :UpdataHosts "%%a" "%~dp0%%b" NotTip
	if not "!return!"=="false" msg "%username%" /time:10 完毕，共更新!return!条有效域名。&exit
	set return=false
)
msg "%username%" /time:10 抱歉，暂无可用的源。&exit
:UpdataHosts
set Dpath=%1
set Npath=%2
set MsMt=%3
if not defined MsMt (set MsMt=msg "%username%" /time:10 ) else set "MsMt=echo,"
set Ppath="%windir%\system32\drivers\etc\hosts"
set Tpath="%~dp0temp.log"
set return=false
set num=0
del /f /s /q %Npath% >nul 2>nul
if not exist "%~dp0wget.exe" (
	call :Temp_Clean
	set return=false
	%MsMt%抱歉，Wget.exe组件丢失。
	goto :eof
)
call "%~dp0wget.exe" %Dpath% >nul 2>nul
if not "%errorlevel%"=="0" (
	call :Temp_Clean
	set return=false
	%MsMt%抱歉，暂时无法链接该源。
	goto :eof
)
del /f /s /q %Ppath% >nul 2>nul
echo,Successfully Download，processing...
echo,#=== Updata Date:%date%-%time%===>%Tpath%
echo.#=== Source:%Dpath% ===>>%Tpath%
for /f "eol=# delims=	 tokens=1,2,3*" %%a in ('type %Npath%') do (
	if not "%%a"=="127.0.0.1" (
		if not "%%a"=="255.255.255.255" (
			if not "%%a"=="::1" (
				if not "%%a"=="fe80::1%%lo0" (
				echo,%%a	%%b>>%Tpath%
				set /a num+=1
				)
			)
		)
	)
)
echo,#=== End Total:%Num% ===>>%Tpath%
del /f /s /q %Npath% >nul 2>nul
copy %Tpath% %Ppath% /y >nul 2>nul
if not "%errorlevel%"=="0" (
	del /f /s /q %Tpath% >nul 2>nul
	call :Temp_Clean
	set return=false
	%MsMt%抱歉，权限不足。
	goto :eof
)
del /f /s /q %Tpath% >nul 2>nul
ipconfig /flushdns
set return=%num%
%MsMt%成功，共更新%num%条有效域名。
call :Temp_Clean
goto :eof
:Temp_Clean
set Dpath=&set Npath=&set Ppath=&set Tpath=&set num=&set MsMt=
goto :eof