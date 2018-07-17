@echo off
cls
echo ##############################################
echo      Windows ����� ������ �����մϴ�.
echo ##############################################
echo.
echo �� boot ������ C:\ ��ġ���� �������ּ���
pause

set filename=result_w.txt
set tempfile=temp
set CURPATH=%CD%
set tempfile1=temp1
set tools=%CURPATH%\tools
::\lib\tools
:: tools ��ġ�� �������̹Ƿ� �����ؾ���

systeminfo | find "OS �̸�:" > osversion_w

ipconfig | find "IPv4 �ּ�" > ip
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
echo ======== 1-1 Administrator ���� ���� ======== > %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
net localgroup Administrators >> %filename%

net localgroup Administrators > %tempfile%
FOR /F "tokens=1,2,3,4 skip=6" %%j IN (%tempfile%) Do echo %%j %%k %%l %%m >> admin-temp

findstr "Administrator" admin-temp > nul
:: findstr "ã���ܾ�" ����

if errorlevel 1 echo Check Result : Safety >> %filename%
if not errorlevel  1 echo Check Result : UnSafe >> %filename%
del admin-temp

:: errorlevel�� ����� ����� ����Ǹ� 0
:: ������ ã���� ������ 1�� ��Ÿ����.

echo ======== 1-2 Guest ���� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%

net user guest | find "Ȱ�� ����" > %tempfile%

findstr "�ƴϿ�" %tempfile% > nul

net user guest | find "Ȱ�� ����" >> %filename%

if errorlevel 1 echo  Check Result : UnSafe >> %filename%
if not errorlevel 1 echo Check Result : Safety >> %filename%


echo ======== 1-3 ���� ��� �Ӱ谪 ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
net accounts | find "��� �Ӱ谪" > %tempfile%
for /f "tokens=3" %%a in (%tempfile%) do set compare_val=%%a

net accounts | find "��� �Ӱ谪" >> %filename%


::if %compare_val%=="�ƴ�" echo Check Result : UnSafe >> %filename%
if not %compare_val% LEQ 5 echo Check Result : UnSafe >> %filename%
if not %compare_val% GTR 5 echo Check Result: Safety >> %filename%

echo ======== 1-4 ���� ��� �Ⱓ ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
net accounts | find "��� �Ⱓ" >> %filename%
::net accounts | find "��� ����" >> %filename%

net accounts | find "��� �Ⱓ" > %tempfile%
for /f "tokens=4" %%a in (%tempfile%) do set compare_val=%%a
if %compare_val% LSS 60 echo Check Result : UnSafe >> %filename%
if %compare_val% GEQ 60 echo Check Result : Safety >> %filename%


::if not %compare_val% GTR 60 goto UnSafe_val
:: if not %compare_val% GEQ 60 echo Check Result : UnSafe >> %filename%

:: ��ݱⰣ�� ��ݰ��� ��� 60�̻��̿��� Safety�� �������ϱ� (������)

::net accounts | find "��� ����" > %tempfile1%
::for /f "tokens=5" %%a in (%tempfile1%) do set compare_val_1=%%a


echo ======== 1-5 ����� ���� ��Ʈ��(UAC) ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "ConsentPromptBehaviorAdmin" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "PromptOnSecureDesktop" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "EnableLUA" >> %filename%

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "EnableLUA" | find "1" > nul
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%



echo ======== 1-6 ���ʿ��� ���� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
echo ���� ���� : Administrator�� ��� >> %filename%
wmic useraccount get status >> %filename%

echo. >> %filename%
wmic useraccount get status | find /c "OK" > %tempfile%
for /f "tokens=1" %%a in (%tempfile%) do set compare_val=%%a
if %compare_val% GEQ 2 echo Check Result : UnSafe >> %filename%
if %compare_val% LSS 2 echo Check Result : Safety >> %filename%


echo ======== 1-7 �ص� ������ ��ȣȭ�� ����Ͽ� ��ȣ ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
secedit /export /cfg C:\secpol.inf
find "ClearTextPassword" C:\secpol.inf >> %filename%

find "ClearTextPassword" C:\secpol.inf | find "1"
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 1-8  Everyone ��� ������ �͸� ����ڿ��� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "everyoneincludesanonymous" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "everyoneincludesanonymous" | find "1" > nul
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%
:: 1 ��� 0 ��ȣ

echo ======== 1-9 �н����� ���� �� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%

find "PasswordComplexity" C:\secpol.inf >> %filename%

find "PasswordComplexity" C:\secpol.inf | find "1"
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%

echo ======== 1-10 �н����� �ּ� ��ȣ ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
net accounts | find "�ּ� ��ȣ ����" >> %filename%
net accounts | find "�ּ� ��ȣ ����" > %tempfile%
for /f "tokens=4" %%a in (%tempfile%) do set compare_val=%%a
if %compare_val% LSS 8 echo Check Result : UnSafe >> %filename%
if %compare_val% GEQ 8 echo Check Result : Safety >> %filename%

echo ======== 1-11 �н����� �ִ� ��� �Ⱓ ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
net accounts | find "�ִ� ��ȣ ��� �Ⱓ" >> %filename%
net accounts | find "�ִ� ��ȣ ��� �Ⱓ" > %tempfile%
for /f "tokens=6" %%a in (%tempfile%) do set compare_val=%%a
if %compare_val% GTR 90 echo Check Result : UnSafe >> %filename%
if %compare_val% LEQ 90 echo Check Result : Safety >> %filename%

echo ======== 1-12 �н����� �ּ� ��� �Ⱓ ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
net accounts | find "�ּ� ��ȣ ��� �Ⱓ" >> %filename%
net accounts | find "�ּ� ��ȣ ��� �Ⱓ" > %tempfile%
for /f "tokens=6" %%a in (%tempfile%) do set compare_val=%%a
if %compare_val% EQU 0  echo Check Result : UnSafe >> %filename%
if %compare_val% GTR 0 echo Check Result : Safety >> %filename%

echo ======== 1-13 ������ ����� �̸� ǥ�� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "dontdisplaylastusername" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "dontdisplaylastusername" | find "1"
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%
:: 1: ��ȣ 0 : ���

echo ======== 1-14 �ֱ� ��ȣ ��� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
net accounts | find "��ȣ ��� ����" >> %filename%
net accounts | find "��ȣ ��� ����" > %tempfile%
for /f "tokens=4" %%a in (%tempfile%) do set compare_val=%%a
if %compare_val% LSS 12  echo Check Result : UnSafe >> %filename%
if %compare_val% GEQ 12 echo Check Result : Safety >> %filename%

echo ======== 1-15 �ܼ� �α׿� �� ���� �������� �� ��ȣ ��� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "LimitBlankPasswordUse" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "LimitBlankPasswordUse" | find "1" > nul
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%
:: find 1 ��ȣ 0 ���

echo ======== 2-1 �������� �� ����ڱ׷� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
net share | find /v "$" | find /v "���" > %tempfile%

for /f "tokens=2 skip=4" %%a in (%tempfile%) do icacls %%a > %tempfile%

type %tempfile% >> %filename%
type %tempfile% | find "Everyone" > nul
if errorlevel 1 echo Check Result : Safety >> %filename%
if not errorlevel 1 echo Check Result : UnSafe >> %filename%


echo ======== 2-2 �ϵ��ũ �⺻���� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
for /f "tokens=1,2,3 skip=4" %%a in ('net share') do echo %%a %%b %%c >> %tempfile%-22
type %tempfile%-22 | find /v "IPC$" | find /v "���" > nul
if errorlevel 1 goto 2-2Safety
if not errorlevel 1 net share | find /v "IPC$" | find /v "���" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" | find "AutoShareWks" >> %filename%
echo Check Result : UnSafe >> %filename%
goto 2-2End

:2-2Safety
echo ���ʿ��� ���丮 ������ �����ϴ�. >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" | find "AutoShareWks"
if not errorlevel 0 echo Check Result : Safety >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" | find "AutoShareWks" > %tempfile%
type %tempfile% | find /v "unable" | find "0" > nul
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%
goto 2-2End

:2-2End
del %tempfile%-22

echo ======== 2-3 CMD_���ϱ��Ѽ��� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : ���� >> %filename%
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

echo ======== 2-4 ����� ���͸� �������� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : ���� >> %filename%
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


echo ======== 2-5 �ֽ� ������ ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : ���� >> %filename%
echo. >> %filename%

%tools%\psinfo | find "pack" >> %filename% 
:: https://support.microsoft.com/ko-kr/help/14162/windows-service-pack-and-update-center

%tools%\psinfo | find "pack" | find "1" > nul
if errorlevel 1 echo Check Result : UnSafe >> %filename%
if not errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 2-6 SNMP ���� ���� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : ���� >> %filename%
echo. >> %filename%

net start 
sc query "SNMPTRAP" | findstr RUNNING >> %filename%
sc query "SNMPTRAP" | findstr RUNNING > nul
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 2-7 ���ʿ��� ���� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
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

echo ======== 2-8 IIS ���� ���� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
echo IIS�� ����ϴµ� ������ �Ǿ��ִ� ���� ���� (�������Ǵ�) >> %filename%
echo ���� ���� IIS�� ������� �ʴ� �ٴ°��� �������� ���

net start | find "IISADMIN" >> %filename%
net start | find "IISADMIN"
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%






echo ======== 3-1 ��� ���α׷� ������Ʈ (V3) ======== >> %filename%
:: ������Ʈ�� ������ ��
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Ahnlab\ASPack\9.0\Update" | find "updatebuild" > %tempfile%-update

for /f "tokens=3" %%a in (%tempfile%-update) do set compare_val=%%a
echo V3 Version : %compare_val% >> %filename%
if not "%compare_val%" EQU "9.0.48.1245" echo Check Result : UnSafe >> %filename%
if "%compare_val%" EQU "9.0.48.1245" echo Check Result : Safety >> %filename%

del %tempfile%-update

echo ======== 4-1 �������� �������� �� �ִ� ������Ʈ�� ��� ======== >> %filename%
echo. >> %filename%

sc query "RemoteRegistry" >> %filename%
sc query "RemoteRegistry" | findstr RUNNING
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 4-2 �̺�Ʈ �α� ���� ���� ======== >> %filename%
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

echo ======== 4-3 ���ݿ��� �̺�Ʈ �α� ���� ���� ���� ======== >> %filename%
echo. >> %filename%

cacls %systemrot%\system32\config | find "Everyone"
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 5-1 ��� ���α׷� ��ġ (V3) ======== >> %filename%

tasklist /FI "IMAGENAME eq V3UI.exe" | find /v "========" >> %filename%
tasklist /FI "IMAGENAME eq V3UI.exe"
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%

echo ======== 5-2 SAM ���� ���� ���� ���� ======== >> %filename%
echo. >> %filename%

cacls %systemroot%\system32\config\SAM | find /I /V "administrators" | find /I /V "system:" > %tempfile%-sam
type %tempfile%-sam | find ":(ID)F" > nul
if errorlevel 1 echo Check Result : Safety >> %filename%
if not errorlevel 1 echo Check Result : UnSafe >> %filename%

del %tempfile%-sam

echo ======== 5-3 ȭ�� ��ȣ�� ���� ======== >> %filename%
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
echo      Windows ����� ������ �Ϸ�Ǿ����ϴ�.
echo ##############################################
echo.
echo  �� report_w.html�� ���� �����ϰ� ����� Ȯ���Ҽ� �ֽ��ϴ�.
pause