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
set tools=%CURPATH%\lib\tools
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

sc query "SNMPTRAP" >> %filename%
net start | find "SNMP Trap" > nul
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

del %tempfile%-ser
del %tempfile%-rem-ser
echo ======== 2-8 IIS 서비스 구동 점검 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%
echo IIS를 사용하는데 실행이 되어있는 경우는 별개 (관리자판단) >> %filename%
echo 현재 툴은 IIS를 사용하지 않는 다는것을 안전으로 취급 >> %filename%

sc query IISADMIN >> %filename%
net start | find "IIS Admin Service" > nul
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 2-9 FTP 서비스 구동 점검 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%

sc query FTPSVC >> %filename%
net start | find "Microsoft FTP Service" > nul

if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 2-10 터미널 서비스 암호화 수준 설정 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"  | find "MinEncryptionLevel" > %tempfile%-ter

for /f "tokens=3" %%a in (%tempfile%-ter) do set compare_val=%%a
if %compare_val% GEQ 2 echo Check Result : Safety >> %filename%
if %compare_val% LSS 2  echo Check Result : UnSafe >> %filename%
del %tempfile%-ter
:: 2(중간)이상 안전

echo ======== 2-11 Telnet 보안 설정 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%

sc query "TlntSvr" >> %filename%
net start | find "Telnet" > nul
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

echo ======== 3-2 정책에 따른 시스템 로깅 설정 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%

find "AuditLogonEvents" C:\secpol.inf >> %filename%
find "AuditPrivilegeUse" C:\secpol.inf >> %filename%
find "AuditPolicyChange" C:\secpol.inf >> %filename%
find "AuditAccountManage" C:\secpol.inf >> %filename%
find "AuditDSAccess" C:\secpol.inf >> %filename%
find "AuditAccountLogon" C:\secpol.inf >> %filename%

find "AuditLogonEvents" C:\secpol.inf | find "3" > nul
if not errorlevel 1 goto sec1-safe
if errorlevel 1 goto sec-fail

:sec1-safe
find "AuditPrivilegeUse" C:\secpol.inf | find "3" > nul
if not errorlevel 1 goto sec2-safe
if errorlevel 1 goto sec-fail

:sec2-safe
find "AuditPolicyChange" C:\secpol.inf | find "3" > nul
if not errorlevel 1 goto sec3-safe
if errorlevel 1 goto sec-fail

:sec3-safe
find "AuditAccountManage" C:\secpol.inf | find "2" > nul
if not errorlevel 1 goto sec4-safe
if errorlevel 1 goto sec-fail

:sec4-safe
find "AuditDSAccess" C:\secpol.inf | find "2" > nul
if not errorlevel 1 goto sec5-safe
if errorlevel 1 goto sec-fail

:sec5-safe
find "AuditAccountLogon" C:\secpol.inf | find "3" > nul
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 goto sec-fail
goto main

:sec-fail
echo Check Result : UnSafe >> %filename%

:main

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
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%
tasklist /FI "IMAGENAME eq V3UI.exe" | find /v "========" >> %filename%
tasklist /FI "IMAGENAME eq V3UI.exe"
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%

echo ======== 5-2 SAM 파일 접근 통제 설정 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%
cacls %systemroot%\system32\config\SAM | find /I /V "administrators" | find /I /V "system:" > %tempfile%-sam
type %tempfile%-sam | find ":(ID)F" > nul
if errorlevel 1 echo Check Result : Safety >> %filename%
if not errorlevel 1 echo Check Result : UnSafe >> %filename%

del %tempfile%-sam

echo ======== 5-3 화면 보호기 설정 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
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

echo ======== 5-4 로그온 하지 않고 시스템 종료 허용 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "shutdownwithoutlogon" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "shutdownwithoutlogon" | find "1" > nul
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

::Window NT => HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
::ShutdownWithoutLogon

echo ======== 5-5 보안 감사를 로그할 수 없는 경우 즉시 시스템 종료 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "crashonauditfail" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "crashonauditfail" | find "1" > nul
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 5-6 SAM 계정과 공유의 익명 열거 허용 안 함 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "restrictanonymous" | find /v "restrictanonymoussam" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find /v "restrictanonymoussam" | find "restrictanonymous" | find "1" > nul
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%


echo ======== 5-7 Autologon 기능 제어 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%
echo 취약점 개요 : *Autologon 기능을 사용하면 침입자가 해킹 도구를 이용하여 레지스트리에서 로그인 >> %filename%
echo 계정 및 암호를 확인할 수 있으므로 기능을 사용하지 않도록 설정함 >> %filename%
echo. >> %filename%
echo 양호 : AutoAdminLogon 값이 없거나 0으로 설정되어 있는 경우 >> %filename%
echo 취약 : AutoAdminLogon 값이 1로 설정되어 있는 경우 >> %filename%

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" | find "AutoAdminLogon" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" | find "AutoAdminLogon" > %tempfile%-autologon
for /f "tokens=3" %%a in (%tempfile%-autologon) do set compareval=%%a
if "%compareval%" GEQ "1" echo Check Result : UnSafe >> %filename%
if "%compareval%" == "0" echo Check Result : Safety >> %filename% 
if "%compareval%" == "" echo Check Result : Safety >> %filename% 
del %tempfile%-autologon

echo ======== 5-8 이동식 미디어 포맷 및 꺼내기 허용 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 상 >> %filename%
echo. >> %filename%
echo 취약점 개요 : 이동식 미디어의 포맷 및 꺼내기가 허용되는 사용자를 제한함으로써 >> %filename%
echo 사용자가 NTFS관리 권한을 갖고 있는 임의의 컴퓨터로만 이동식 디스크의 데이터를 이동하고 >> %filename%
echo 파일에 대한 소유권을 얻어 파일을 보거나 수정할 수 있도록 함. >> %filename%
echo 계정 및 암호를 확인할 수 있으므로 기능을 사용하지 않도록 설정함 >> %filename%
echo. >> %filename%
echo 양호 : 이동식 미디어 포맷 및 꺼내기 허용 정책이 "Administrator" 로 되어 있는 경우 >> %filename%
echo 취약 : 허용 정책이 "Administrator"로 되어 있지 않은 경우 >> %filename%

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" | find "AllocateDASD" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" | find "AllocateDASD" > %tempfile%-ntfs
for /f "tokens=3" %%a in (%tempfile%-ntfs) do set compareval=%%a
if "%compareval%" GEQ "1" echo Check Result : UnSafe >> %filename%
if "%compareval%" == "" echo Check Result : UnSafe >> %filename%
if "%compareval%" == "0" echo Check Result : Safety >> %filename% 
del %tempfile%-ntfs

echo ======== 5-9 사용자가 프린터 드라이버를 설치할 수 없게 함 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%
echo 취약점 개요 : 서버에 프린터 드라이버를 설치하는 경우 악의적인 사용자가 고의적으로 >> %filename%
echo 잘못된 프린터 드라이버를 설치하여 컴퓨터를 손상시킬 수 있으며 프린터 드라이버로 >> %filename%
echo 위장한악성 코드를 설치할 수 있으므로 사용자가 프린터 드라이버를 설치할 수 없게 설정하여야 함. >> %filename%
echo. >> %filename%
echo 양호 : 사용자가 프린터 드라이버를 설치할 수 없게 함 정책이 "사용" 인 경우  >> %filename%
echo 취약 : 정책이 "사용 안 함" 인 경우 >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" | find "AddPrinterDrivers" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" | find "AddPrinterDrivers" | find "1" > nul
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%

echo ======== 5-10 세션 연결을 중단하기 전에 필요한 유휴시간 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%
echo 취약점 개요 : 세션이 중단되기 전에 SMB(서버메세지블록) 세션에서 보내야하는 연속 유휴시간을 결정할수 있음 >> %filename%
echo 공격자는 이를 악용하여 SMB 세션을 반복 설정하여 서버의 SMB 서비스가 느려지거나 응답하지않게하여 DOS 공격을 실행 가능 >> %filename%
echo *SMB( ): LAN 서버 메시지 블록 이나 컴퓨터 간의 통신에서 데이터 송수신을 하기 위한 프로토콜 >> %filename%
echo. >> %filename%
echo 양호 : "로그온 시간이 만료되면 클라이언트 연결 끊기" 정책을 "사용"  >> %filename%
echo "세션 연결을 중단하기 전에 필요한 유휴 시간" 정책을 "15분" 으로 설정한 경우  >> %filename%
echo 취약 : 정책이 "사용 안 함"이고, "15분"이 아닌 경우 >> %filename%


reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" | find "enableforcedlogoff" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" | find "autodisconnect" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" | find "enableforcedlogoff" > %tempfile%-enforce
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" | find "autodisconnect" > %tempfile%-autodcon
for /f "tokens=3" %%a in (%tempfile%-enforce) do set compare-enforce=%%a
for /f "tokens=3" %%a in (%tempfile%-autodcon) do set compare-autodcon=%%a
if "%compare-enforce%" == "0x1" (
if "%compare-autodcon%" == "0xf" (
echo Check Result : Safety >> %filename%) else ( 
echo Check Result : UnSafe >> %filename%) ) else (
echo Check Result : UnSafe >> %filename% )
del %tempfile%-enforce
del %tempfile%-autodcon

echo ======== 5-11 경고 메시지 설정 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 하 >> %filename%
echo. >> %filename%
echo 취약점 개요 : 시스템에 로그온을 시도하는 사용자들에게 관리자는 시스템의 불법적인 사용에 대하여 경고 창을 띄움으로써 경각심을 줄 수 있음 >> %filename%
echo 악의적인 사용자에게 관리자가 적절한 보안수준으로 시스템을 보호하고있으며, 공격자의 활동을 주시하고 있다는 >> %filename%
echo 생각을 상기시킴으로써 간접적으로 공격 피해를 감소시키는 효과를 볼 수 있음 >> %filename%
echo. >> %filename%
echo 양호 : 로그인 경고 메시지제목 및 내용이 설정되어 있는 경우  >> %filename%
echo 취약 : 설정이 되어있지 않은 경우 >> %filename%


reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" | find "LegalNoticeCaption" > %tempfile%-warning-ti
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" | find "LegalNoticeText" > %tempfile%-warning-te
for /f "tokens=3" %%a in (%tempfile%-warning-ti) do set compare_warn_ti=%%a
for /f "tokens=3" %%a in (%tempfile%-warning-te) do set compare_warn_te=%%a
echo. >> %filename%
echo 경고 메시지 제목 : %compare_warn_ti% >> %filename%
echo 경고 메시지 내용 : %compare_warn_te% >> %filename%

if "%compare_warn_ti%" == "" (
echo Check Result : UnSafe >> %filename% ) else (
if "%compare_warn_te%" == "" (
echo Check Result : UnSafe >> %filename% ) else (
echo Check Result : Safety >> %filename% ))

del %tempfile%-warning-te
del %tempfile%-warning-ti

echo ======== 5-12 LAN Manager 인증 수준 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%
echo 취약점 개요 : *Lan Manager 인증 수준 설정을 통해 네트워크 로그온에 사용할 >> %filename%
echo Challenge/Response 인증 프로토콜을 결정하며 이 설정은 클라이언트가 사용하는 >> %filename%
echo 인증 프로토콜 수준, 협상된 세션 보안 수준 및 서버가 사용하는 인증 수준에 >> %filename%
echo 영향을 주기 때문에 보다안전한 인증을 위해 를 사용하는 것을 권장함 >> %filename%

echo. >> %filename%
echo 양호 : "LAN Manager " 인증 수준 정책에 "NTLMv2 응답만 보냄" 이 설정되어 있는 경우  >> %filename%
echo 취약 : "LAN Manager " 인증 수준 정책에 "LM" 및 "NTLM"인증이 설정되어 있는 경우 >> %filename%

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "LmCompatibilityLevel" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "LmCompatibilityLevel" > nul
if errorlevel 1 echo Check Result : UnSafe >> %filename%
if not errorlevel 1 goto LANLevel
goto 5-12end

:LANLevel
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "LmCompatibilityLevel" > %tempfile%-lanlevel
for /f "tokens=3" %%a in (%tempfile%-lanlevel) do set compare_lan=%%a
if "%compare_lan%" == "0x3" (
echo Check Result : Safety >> %filename% ) else (
echo Check Result : UnSafe >> %filename% )

:5-12end
del %tempfile%-lanlevel

echo ======== 5-13 보안 채널 데이터 디지털 암호화 또는, 서명 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%
echo 취약점 개요 : 보안 채널 데이터 디지털 암호화 또는, 서명 설정을 통해 도메인 구성원이 시작한 >> %filename%
echo 모든 보안 챈러 트래픽이 최소 보안 요구 사항을 충족해야하는지를 설정 >> %filename%
echo 인증 트래픽 끼어들기 공격 반복 공격 및 기타 유형의 네트워크 공격으로부터 보호하기 위해  >> %filename%
echo Windows 기반에서는 NetLogon을 통해 보안 채널이라는 통신 채널을 만들어 컴퓨터 및 사용자 계정에 대한 인증을 함. >> %filename%

echo. >> %filename%
echo 양호 : 아래 3가지 정책이 "사용"으로 되어 있는 경우  >> %filename%
echo 취약 : 아래 3가지 정책이 "사용 안 함"으로 되어 있는 경우 >> %filename%
echo * 도메인 구성원 : 보안채널데이터를 디지털 암호화 또는 서명(항상) >> %filename%
echo * 도메인 구성원 : 보안채널데이터를 디지털 암호화(가능한 경우) >> %filename%
echo * 도메인 구성원 : 보안채널데이터를 디지털 서명(가능한 경우) >> %filename%

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" | find "RequireSignOrSeal" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" | find "SealSecureChannel" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" | find "SignSecureChannel" >> %filename%

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" | find "RequireSignOrSeal" > %tempfile%-rsos
for /f "tokens=3" %%a in (%tempfile%-rsos) do set compare-rsos=%%a
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" | find "SealSecureChannel" > %tempfile%-ssc1
for /f "tokens=3" %%a in (%tempfile%-ssc1) do set compare-ssc1=%%a
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" | find "SignSecureChannel" > %tempfile%-ssc2
for /f "tokens=3" %%a in (%tempfile%-ssc2) do set compare-ssc2=%%a

if "%compare-rsos%" == "0x1" (
if "%compare-ssc1%" == "0x1" (
if "%compare-ssc2%" == "0x1" (
echo Check Result : Safety >> %filename% ) else ( 
echo Check Result : UnSafe >> %filename%) ) else ( 
echo Check Result : UnSafe >> %filename% ) ) else ( 
echo Check Result : UnSafe >> %filename% )
del %tempfile%-rsos
del %tempfile%-ssc1
del %tempfile%-ssc2
echo ======== 5-14 파일 및 디렉터리 보호 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%
echo 취약점 개요 : NTFS 파일 시스템은 포맷 시 모든 파일과 디렉터리에 소유권과 >> %filename%
echo 사용 권한 설정이 가능하고 접근 통제 목록 을 제공함으로써 파일 시스템에 비해 >> %filename%
echo 보다 강화 ACL( ) *FAT된 보안 기능을 제공 >> %filename%

echo. >> %filename%
echo 양호 : NTFS 파일 시스템을 사용하는 경우  >> %filename%
echo 취약 : FAT파일 시스템을 사용하는 경우 >> %filename%

echo list volume | diskpart >> %filename%
echo list volume | diskpart | findstr FAT > nul
echo. >> %filename%
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 5-15 컴퓨터 계정 암호 최대 사용 기간 ======== >> %filename%
echo. >> %filename%
echo 항목중요도 : 중 >> %filename%
echo. >> %filename%
echo 취약점 개요 : NTFS 파일 시스템은 포맷 시 모든 파일과 디렉터리에 소유권과 >> %filename%
echo 사용 권한 설정이 가능하고 접근 통제 목록 을 제공함으로써 파일 시스템에 비해 >> %filename%
echo 보다 강화 ACL( ) *FAT된 보안 기능을 제공 >> %filename%

echo. >> %filename%
echo 양호 : "컴퓨터 계정 암호 변경 사용 안 함" 정책을 사용하지 않으며,  >> %filename%
echo "컴퓨터 게정 암호 최대 사용 기간" 정책이 "90"일(0x5a)로 설정되어 있는 경우  >> %filename%
echo 취약 : 정책이 "사용"으로 설정되어있거나, "90일"로 설정되어 있지 않은 경우 >> %filename%

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" | find "DisablePasswordChange" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" | find "MaximumPasswordAge" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" | find "DisablePasswordChange" > %tempfile%-dpc
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" | find "MaximumPasswordAge" > %tempfile%-mpa
for /f "tokens=3" %%a in (%tempfile%-dpc) do set compare-dpc=%%a
for /f "tokens=3" %%a in (%tempfile%-mpa) do set compare-mpa=%%a

if "%compare-dpc%" == "0x0" (
if "%compare-mpa%" == "0x5a" ( 
echo Check Result : Safety >> %filename% ) else (
echo Check Result : UnSafe >> %filename% ) ) else ( 
echo Check Result : UnSafe >> %filename% )
::DisablePasswordChange 0 안전
::MaximumPasswordAge 90 안전
del %tempfile%-dpc
del %tempfile%-mpa

:: #2018-7-4 Script the End 
cls
echo ##############################################
echo      Windows 취약점 점검이 완료되었습니다.
echo ##############################################
echo.
echo  ※ report_w.html을 통해 간략하게 결과를 확인할수 있습니다.
pause