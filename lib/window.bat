@echo off
cls
echo ##############################################
echo      Windows 취약점 점검을 시작합니다.
echo ##############################################
echo.
echo ※ boot 폴더를 C:\ 위치에서 진행해주세요
pause

set filename=result_w.txt
set tempfile=temp
set CURPATH=%CD%
set tempfile1=temp1
set tools=%CURPATH%\tools
::\lib\tools
:: tools 위치는 절대경로이므로 수정해야함

systeminfo | find "OS 이름:" > osversion_w

ipconfig | find "IPv4 주소" > ip
if not errorlevel 1 goto hangul
if errorlevel 1 goto eng

:eng
ipconfig | find "IP Address" > ip
for /f "tokens=15" %%a in (ip) do echo %%a > ip
goto main

:hangul
for /f "tokens=13" %%a in (ip) do echo %%a > ip
goto main

:main
echo ======== 1-1 Administrator 계정 관리 ======== > %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%
net localgroup Administrators >> %filename%

net localgroup Administrators > %tempfile%
FOR /F "tokens=1,2,3,4 skip=6" %%j IN (%tempfile%) Do echo %%j %%k %%l %%m >> admin-temp

findstr "Administrator" admin-temp > nul
:: findstr "찾을단어" 파일

if errorlevel 1 echo Check Result : Safety >> %filename%
if not errorlevel  1 echo Check Result : UnSafe >> %filename%
del admin-temp

:: errorlevel은 명령이 제대로 실행되면 0
:: 파일을 찾을수 없으면 1로 나타난다.

echo ======== 1-2 Guest 계정 관리 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%

net user guest | find "활성 계정" > %tempfile%

findstr "아니요" %tempfile% > nul

net user guest | find "활성 계정" >> %filename%

if errorlevel 1 echo  Check Result : UnSafe >> %filename%
if not errorlevel 1 echo Check Result : Safety >> %filename%


echo ======== 1-3 계정 잠금 임계값 설정 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%
net accounts | find "잠금 임계값" > %tempfile%
for /f "tokens=3" %%a in (%tempfile%) do set compare_val=%%a

net accounts | find "잠금 임계값" >> %filename%


::if %compare_val%=="아님" echo Check Result : UnSafe >> %filename%
if not %compare_val% LEQ 5 echo Check Result : UnSafe >> %filename%
if not %compare_val% GTR 5 echo Check Result: Safety >> %filename%

echo ======== 1-4 계정 잠금 기간 설정 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%
net accounts | find "잠금 기간" >> %filename%
::net accounts | find "잠금 관찰" >> %filename%

net accounts | find "잠금 기간" > %tempfile%
for /f "tokens=4" %%a in (%tempfile%) do set compare_val=%%a
if %compare_val% LSS 60 echo Check Result : UnSafe >> %filename%
if %compare_val% GEQ 60 echo Check Result : Safety >> %filename%


::if not %compare_val% GTR 60 goto UnSafe_val
:: if not %compare_val% GEQ 60 echo Check Result : UnSafe >> %filename%

:: 잠금기간과 잠금관찰 모두 60이상이여야 Safety로 나오게하기 (수정전)

::net accounts | find "잠금 관찰" > %tempfile1%
::for /f "tokens=5" %%a in (%tempfile1%) do set compare_val_1=%%a


echo ======== 1-5 사용자 계정 컨트롤(UAC) 설정 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "ConsentPromptBehaviorAdmin" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "PromptOnSecureDesktop" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "EnableLUA" >> %filename%

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "EnableLUA" | find "1" > nul
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%



echo ======== 1-6 불필요한 계정 제거 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%
echo 점검 기준 : Administrator만 사용 >> %filename%
wmic useraccount get status >> %filename%

echo. >> %filename%
wmic useraccount get status | find /c "OK" > %tempfile%
for /f "tokens=1" %%a in (%tempfile%) do set compare_val=%%a
if %compare_val% GEQ 2 echo Check Result : UnSafe >> %filename%
if %compare_val% LSS 2 echo Check Result : Safety >> %filename%


echo ======== 1-7 해독 가능한 암호화를 사용하여 암호 저장 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%
secedit /export /cfg C:\secpol.inf
find "ClearTextPassword" C:\secpol.inf >> %filename%

find "ClearTextPassword" C:\secpol.inf | find "1"
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 1-8  Everyone 사용 권한을 익명 사용자에게 적용 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "everyoneincludesanonymous" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "everyoneincludesanonymous" | find "1" > nul
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%
:: 1 취약 0 양호

echo ======== 1-9 패스워드 복잡 성 설정 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%

find "PasswordComplexity" C:\secpol.inf >> %filename%

find "PasswordComplexity" C:\secpol.inf | find "1"
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%

echo ======== 1-10 패스워드 최소 암호 길이 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%
net accounts | find "최소 암호 길이" >> %filename%
net accounts | find "최소 암호 길이" > %tempfile%
for /f "tokens=4" %%a in (%tempfile%) do set compare_val=%%a
if %compare_val% LSS 8 echo Check Result : UnSafe >> %filename%
if %compare_val% GEQ 8 echo Check Result : Safety >> %filename%

echo ======== 1-11 패스워드 최대 사용 기간 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%
net accounts | find "최대 암호 사용 기간" >> %filename%
net accounts | find "최대 암호 사용 기간" > %tempfile%
for /f "tokens=6" %%a in (%tempfile%) do set compare_val=%%a
if %compare_val% GTR 90 echo Check Result : UnSafe >> %filename%
if %compare_val% LEQ 90 echo Check Result : Safety >> %filename%

echo ======== 1-12 패스워드 최소 사용 기간 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%
net accounts | find "최소 암호 사용 기간" >> %filename%
net accounts | find "최소 암호 사용 기간" > %tempfile%
for /f "tokens=6" %%a in (%tempfile%) do set compare_val=%%a
if %compare_val% EQU 0  echo Check Result : UnSafe >> %filename%
if %compare_val% GTR 0 echo Check Result : Safety >> %filename%

echo ======== 1-13 마지막 사용자 이름 표시 안함 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "dontdisplaylastusername" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "dontdisplaylastusername" | find "1"
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%
:: 1: 양호 0 : 취약

echo ======== 1-14 최근 암호 기억 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%
net accounts | find "암호 기록 개수" >> %filename%
net accounts | find "암호 기록 개수" > %tempfile%
for /f "tokens=4" %%a in (%tempfile%) do set compare_val=%%a
if %compare_val% LSS 12  echo Check Result : UnSafe >> %filename%
if %compare_val% GEQ 12 echo Check Result : Safety >> %filename%

echo ======== 1-15 콘솔 로그온 시 로컬 계정에서 빈 암호 사용 제한 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "LimitBlankPasswordUse" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "LimitBlankPasswordUse" | find "1" > nul
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%
:: find 1 양호 0 취약

echo ======== 2-1 공유권한 및 사용자그룹 설정 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%
net share | find /v "$" | find /v "명령" > %tempfile%

for /f "tokens=2 skip=4" %%a in (%tempfile%) do icacls %%a > %tempfile%

type %tempfile% >> %filename%
type %tempfile% | find "Everyone" > nul
if errorlevel 1 echo Check Result : Safety >> %filename%
if not errorlevel 1 echo Check Result : UnSafe >> %filename%


echo ======== 2-2 하드디스크 기본공유 제거 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%
for /f "tokens=1,2,3 skip=4" %%a in ('net share') do echo %%a %%b %%c >> %tempfile%-22
type %tempfile%-22 | find /v "IPC$" | find /v "명령" > nul
if errorlevel 1 goto 2-2Safety
if not errorlevel 1 net share | find /v "IPC$" | find /v "명령" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" | find "AutoShareWks" >> %filename%
echo Check Result : UnSafe >> %filename%
goto 2-2End

:2-2Safety
echo 불필요한 디렉토리 공유가 없습니다. >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" | find "AutoShareWks"
if not errorlevel 0 echo Check Result : Safety >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" | find "AutoShareWks" > %tempfile%
type %tempfile% | find /v "unable" | find "0" > nul
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%
goto 2-2End

:2-2End
del %tempfile%-22

echo ======== 2-3 CMD_파일권한설정 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 미정 >> %filename%
echo. >> %filename%
cacls %systemroot%\system32\cmd.exe | find /I /V "administrator" | find /I /V "system:" | find /I /V "TrustedInstaller:" > %tempfile%-23
type %tempfile%-23 | find ":F" > nul
if not errorlevel 1 goto 2-3UnSafe

type %tempfile%-23 | find ":C" > nul
if not errorlevel 1 goto 2-3UnSafe

type %tempfile%-23 | find "FILE_EXECUTE" > nul
if not errorlevel 1 goto 2-3UnSafe

if errorlevel 1 goto 2-3Safety

:2-3UnSafe
echo Check Result : UnSafe >> %filename%
goto 2-3End

:2-3Safety
echo Check Result : Safety >> %filename%
goto 2-3End

:2-3End
del %tempfile%-23

echo ======== 2-4 사용자 디렉터리 접근제한 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 미정 >> %filename%
echo. >> %filename%

cacls "c:\users\*" > %tempfile%-user
type %tempfile%-user | find "User:(OI) (CI) F" > nul
if errorlevel 1 goto no-user
if not errorlevel 1 goto yes-user

:no-user
type %tempfile%-user | find "Everyone:(OI) (CI)F" > nul
if errorlevel 1 echo Check Result : Safety >> %filename%
if not errorlevel 1 Check Result : UnSafe >> %filename%
goto 2-4End

:yes-user
type %tempfile%-user | find "Everyone:(OI) (CI)F" > nul
if errorlevel 1 echo Check Result : UnSafe >> %filename%
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
goto 2-4End

:2-4End
del %tempfile%-user


echo ======== 2-5 최신 서비스팩 적용 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 미정 >> %filename%
echo. >> %filename%

%tools%\psinfo | find "pack" >> %filename% 
:: https://support.microsoft.com/ko-kr/help/14162/windows-service-pack-and-update-center

%tools%\psinfo | find "pack" | find "1" > nul
if errorlevel 1 echo Check Result : UnSafe >> %filename%
if not errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 2-6 SNMP 서비스 구동 점검 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 미정 >> %filename%
echo. >> %filename%

net start 
sc query "SNMPTRAP" | findstr RUNNING >> %filename%
sc query "SNMPTRAP" | findstr RUNNING > nul
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 2-7 불필요한 서비스 제거 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%

sc query | findstr "simptcp" > %tempfile%-ser
sc query | findstr "clipbook" >> %tempfile%-ser
sc query | findstr "messenger" >> %tempfile%-ser
sc query | findstr "alerter" >> %tempfile%-ser

find /v /c %tempfile%-ser "" > %tempfile%-rem-ser
for /f "tokens=3" %%a in (%tempfile%-rem-ser) do set compare_val=%%a
if %compare_val% EQU 0 echo Check Result : Safety >> %filename%
if %compare_val% GEQ 1 echo Check Result : UnSafe >> %filename%

if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 2-8 IIS 서비스 구동 점검 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%
echo IIS를 사용하는데 실행이 되어있는 경우는 별개 (관리자판단) >> %filename%
echo 현재 툴은 IIS를 사용하지 않는 다는것을 안전으로 취급

net start | find "IISADMIN" >> %filename%
net start | find "IISADMIN"
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%






echo ======== 3-1 백신 프로그램 업데이트 (V3) ======== >> %filename%
:: 레지스트리 값으로 비교
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Ahnlab\ASPack\9.0\Update" | find "updatebuild" > %tempfile%-update

for /f "tokens=3" %%a in (%tempfile%-update) do set compare_val=%%a
echo V3 Version : %compare_val% >> %filename%
if not "%compare_val%" EQU "9.0.48.1245" echo Check Result : UnSafe >> %filename%
if "%compare_val%" EQU "9.0.48.1245" echo Check Result : Safety >> %filename%

del %tempfile%-update

echo ======== 4-1 원격으로 엑세스할 수 있는 레지스트리 경로 ======== >> %filename%
echo. >> %filename%

sc query "RemoteRegistry" >> %filename%
sc query "RemoteRegistry" | findstr RUNNING
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 4-2 이벤트 로그 관리 설정 ======== >> %filename%
echo. >> %filename%
echo. > %tempfile%-event
for /f "tokens=3" %%a in ('%tools%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Application\MaxSize"') do set compare_val=%%a
if not "%compare_val%" GEQ "10485760" echo UnSafe >> %tempfile%-event

for /f "tokens=3" %%a in ('%tools%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Security\MaxSize"') do set compare_val=%%a
if not "%compare_val%" GEQ "10485760" echo UnSafe >> %tempfile%-event

for /f "tokens=3" %%a in ('%tools%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\System\MaxSize"') do set compare_val=%%a
if not "%compare_val%" GEQ "10485760" echo UnSafe >> %tempfile%-event

for /f "tokens=3" %%a in ('%tools%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Application\Retention"') do set compare_val=%%a
if not "%compare_val%" EQU "0" echo UnSafe >> %tempfile%-event 

for /f "tokens=3" %%a in ('%tools%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Security\Retention"') do set compare_val=%%a
if not "%compare_val%" EQU "0" echo UnSafe >> %tempfile%-event

for /f "tokens=3" %%a in ('%tools%\reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\System\Retention"') do set compare_val=%%a
if not "%compare_val%" EQU "0" echo UnSafe >> %tempfile%-event 

type %tempfile%-event | find "UnSafe"
if errorlevel 1 echo  Check Result : Safety >> %filename%
if not errorlevel 1 echo Check Result : UnSafe >> %filename%

del %tempfile%-event

echo ======== 4-3 원격에서 이벤트 로그 파일 접근 차단 ======== >> %filename%
echo. >> %filename%

cacls %systemrot%\system32\config | find "Everyone"
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 5-1 백신 프로그램 설치 (V3) ======== >> %filename%

tasklist /FI "IMAGENAME eq V3UI.exe" | find /v "========" >> %filename%
tasklist /FI "IMAGENAME eq V3UI.exe"
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%

echo ======== 5-2 SAM 파일 접근 통제 설정 ======== >> %filename%
echo. >> %filename%

cacls %systemroot%\system32\config\SAM | find /I /V "administrators" | find /I /V "system:" > %tempfile%-sam
type %tempfile%-sam | find ":(ID)F" > nul
if errorlevel 1 echo Check Result : Safety >> %filename%
if not errorlevel 1 echo Check Result : UnSafe >> %filename%

del %tempfile%-sam

echo ======== 5-3 화면 보호기 설정 ======== >> %filename%
echo. >> %filename%

echo. > %tempfile%-screen
%tools%\reg query "HKEY_CURRENT_USER\Control Panel\Desktop\ScreenSaveActive" >> %tempfile%-screen
%tools%\reg query "HKEY_CURRENT_USER\Control Panel\Desktop\ScreenSaverIsSecure" >> %tempfile%-screen
%tools%\reg query "HKEY_CURRENT_USER\Control Panel\Desktop\ScreenSaveTimeOut" >> %tempfile%-screen

::type %tempfile%-screen | find "ScreenSaveActive" | find "1" > nul
::if errorlevel 1 echo UnSafe
::if not errorlevel 1 echo Safety

type %tempfile%-screen | find "ScreenSaverIsSecure" | find "1" > nul
if errorlevel 1 echo Check Result : UnSafe >> %filename%
if not errorlevel 1 goto 5-3Safety
goto 5-3End

:5-3Safety
type %tempfile%-screen | find "ScreenSaveTimeOut" > %tempfile%-timeout
for /f "tokens=3" %%a in (%tempfile%-timeout) do set compare_val=%%a
if "%compare_val%" GEQ "600" echo Check Result : Safety >> %filename%
if not "%compare_val%" GEQ "600" echo Check Result : UnSafe >> %filename%
del %tempfile%-timeout
goto 5-3End

:5-3End
del %tempfile%-screen
del %tempfile%


:: #2018-7-4 Script the End 
cls
echo ##############################################
echo      Windows 취약점 점검이 완료되었습니다.
echo ##############################################
echo.
echo  ※ report_w.html을 통해 간략하게 결과를 확인할수 있습니다.
pause