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
set tools=%CURPATH%\lib\tools
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

sc query "SNMPTRAP" >> %filename%
net start | find "SNMP Trap" > nul
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

del %tempfile%-ser
del %tempfile%-rem-ser
echo ======== 2-8 IIS ���� ���� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
echo IIS�� ����ϴµ� ������ �Ǿ��ִ� ���� ���� (�������Ǵ�) >> %filename%
echo ���� ���� IIS�� ������� �ʴ� �ٴ°��� �������� ��� >> %filename%

sc query IISADMIN >> %filename%
net start | find "IIS Admin Service" > nul
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 2-9 FTP ���� ���� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%

sc query FTPSVC >> %filename%
net start | find "Microsoft FTP Service" > nul

if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 2-10 �͹̳� ���� ��ȣȭ ���� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"  | find "MinEncryptionLevel" > %tempfile%-ter

for /f "tokens=3" %%a in (%tempfile%-ter) do set compare_val=%%a
if %compare_val% GEQ 2 echo Check Result : Safety >> %filename%
if %compare_val% LSS 2  echo Check Result : UnSafe >> %filename%
del %tempfile%-ter
:: 2(�߰�)�̻� ����

echo ======== 2-11 Telnet ���� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%

sc query "TlntSvr" >> %filename%
net start | find "Telnet" > nul
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

echo ======== 3-2 ��å�� ���� �ý��� �α� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
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
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
tasklist /FI "IMAGENAME eq V3UI.exe" | find /v "========" >> %filename%
tasklist /FI "IMAGENAME eq V3UI.exe"
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%

echo ======== 5-2 SAM ���� ���� ���� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
cacls %systemroot%\system32\config\SAM | find /I /V "administrators" | find /I /V "system:" > %tempfile%-sam
type %tempfile%-sam | find ":(ID)F" > nul
if errorlevel 1 echo Check Result : Safety >> %filename%
if not errorlevel 1 echo Check Result : UnSafe >> %filename%

del %tempfile%-sam

echo ======== 5-3 ȭ�� ��ȣ�� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
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

echo ======== 5-4 �α׿� ���� �ʰ� �ý��� ���� ��� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "shutdownwithoutlogon" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find "shutdownwithoutlogon" | find "1" > nul
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

::Window NT => HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
::ShutdownWithoutLogon

echo ======== 5-5 ���� ���縦 �α��� �� ���� ��� ��� �ý��� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "crashonauditfail" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "crashonauditfail" | find "1" > nul
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 5-6 SAM ������ ������ �͸� ���� ��� �� �� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find "restrictanonymous" | find /v "restrictanonymoussam" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" | find /v "restrictanonymoussam" | find "restrictanonymous" | find "1" > nul
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%


echo ======== 5-7 Autologon ��� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
echo ����� ���� : *Autologon ����� ����ϸ� ħ���ڰ� ��ŷ ������ �̿��Ͽ� ������Ʈ������ �α��� >> %filename%
echo ���� �� ��ȣ�� Ȯ���� �� �����Ƿ� ����� ������� �ʵ��� ������ >> %filename%
echo. >> %filename%
echo ��ȣ : AutoAdminLogon ���� ���ų� 0���� �����Ǿ� �ִ� ��� >> %filename%
echo ��� : AutoAdminLogon ���� 1�� �����Ǿ� �ִ� ��� >> %filename%

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" | find "AutoAdminLogon" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" | find "AutoAdminLogon" > %tempfile%-autologon
for /f "tokens=3" %%a in (%tempfile%-autologon) do set compareval=%%a
if "%compareval%" GEQ "1" echo Check Result : UnSafe >> %filename%
if "%compareval%" == "0" echo Check Result : Safety >> %filename% 
if "%compareval%" == "" echo Check Result : Safety >> %filename% 
del %tempfile%-autologon

echo ======== 5-8 �̵��� �̵�� ���� �� ������ ��� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
echo ����� ���� : �̵��� �̵���� ���� �� �����Ⱑ ���Ǵ� ����ڸ� ���������ν� >> %filename%
echo ����ڰ� NTFS���� ������ ���� �ִ� ������ ��ǻ�ͷθ� �̵��� ��ũ�� �����͸� �̵��ϰ� >> %filename%
echo ���Ͽ� ���� �������� ��� ������ ���ų� ������ �� �ֵ��� ��. >> %filename%
echo ���� �� ��ȣ�� Ȯ���� �� �����Ƿ� ����� ������� �ʵ��� ������ >> %filename%
echo. >> %filename%
echo ��ȣ : �̵��� �̵�� ���� �� ������ ��� ��å�� "Administrator" �� �Ǿ� �ִ� ��� >> %filename%
echo ��� : ��� ��å�� "Administrator"�� �Ǿ� ���� ���� ��� >> %filename%

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" | find "AllocateDASD" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" | find "AllocateDASD" > %tempfile%-ntfs
for /f "tokens=3" %%a in (%tempfile%-ntfs) do set compareval=%%a
if "%compareval%" GEQ "1" echo Check Result : UnSafe >> %filename%
if "%compareval%" == "" echo Check Result : UnSafe >> %filename%
if "%compareval%" == "0" echo Check Result : Safety >> %filename% 
del %tempfile%-ntfs

echo ======== 5-9 ����ڰ� ������ ����̹��� ��ġ�� �� ���� �� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
echo ����� ���� : ������ ������ ����̹��� ��ġ�ϴ� ��� �������� ����ڰ� ���������� >> %filename%
echo �߸��� ������ ����̹��� ��ġ�Ͽ� ��ǻ�͸� �ջ��ų �� ������ ������ ����̹��� >> %filename%
echo �����ѾǼ� �ڵ带 ��ġ�� �� �����Ƿ� ����ڰ� ������ ����̹��� ��ġ�� �� ���� �����Ͽ��� ��. >> %filename%
echo. >> %filename%
echo ��ȣ : ����ڰ� ������ ����̹��� ��ġ�� �� ���� �� ��å�� "���" �� ���  >> %filename%
echo ��� : ��å�� "��� �� ��" �� ��� >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" | find "AddPrinterDrivers" >> %filename%
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" | find "AddPrinterDrivers" | find "1" > nul
if not errorlevel 1 echo Check Result : Safety >> %filename%
if errorlevel 1 echo Check Result : UnSafe >> %filename%

echo ======== 5-10 ���� ������ �ߴ��ϱ� ���� �ʿ��� ���޽ð� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
echo ����� ���� : ������ �ߴܵǱ� ���� SMB(�����޼������) ���ǿ��� �������ϴ� ���� ���޽ð��� �����Ҽ� ���� >> %filename%
echo �����ڴ� �̸� �ǿ��Ͽ� SMB ������ �ݺ� �����Ͽ� ������ SMB ���񽺰� �������ų� ���������ʰ��Ͽ� DOS ������ ���� ���� >> %filename%
echo *SMB( ): LAN ���� �޽��� ��� �̳� ��ǻ�� ���� ��ſ��� ������ �ۼ����� �ϱ� ���� �������� >> %filename%
echo. >> %filename%
echo ��ȣ : "�α׿� �ð��� ����Ǹ� Ŭ���̾�Ʈ ���� ����" ��å�� "���"  >> %filename%
echo "���� ������ �ߴ��ϱ� ���� �ʿ��� ���� �ð�" ��å�� "15��" ���� ������ ���  >> %filename%
echo ��� : ��å�� "��� �� ��"�̰�, "15��"�� �ƴ� ��� >> %filename%


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

echo ======== 5-11 ��� �޽��� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
echo ����� ���� : �ý��ۿ� �α׿��� �õ��ϴ� ����ڵ鿡�� �����ڴ� �ý����� �ҹ����� ��뿡 ���Ͽ� ��� â�� ������ν� �氢���� �� �� ���� >> %filename%
echo �������� ����ڿ��� �����ڰ� ������ ���ȼ������� �ý����� ��ȣ�ϰ�������, �������� Ȱ���� �ֽ��ϰ� �ִٴ� >> %filename%
echo ������ ����Ŵ���ν� ���������� ���� ���ظ� ���ҽ�Ű�� ȿ���� �� �� ���� >> %filename%
echo. >> %filename%
echo ��ȣ : �α��� ��� �޽������� �� ������ �����Ǿ� �ִ� ���  >> %filename%
echo ��� : ������ �Ǿ����� ���� ��� >> %filename%


reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" | find "LegalNoticeCaption" > %tempfile%-warning-ti
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" | find "LegalNoticeText" > %tempfile%-warning-te
for /f "tokens=3" %%a in (%tempfile%-warning-ti) do set compare_warn_ti=%%a
for /f "tokens=3" %%a in (%tempfile%-warning-te) do set compare_warn_te=%%a
echo. >> %filename%
echo ��� �޽��� ���� : %compare_warn_ti% >> %filename%
echo ��� �޽��� ���� : %compare_warn_te% >> %filename%

if "%compare_warn_ti%" == "" (
echo Check Result : UnSafe >> %filename% ) else (
if "%compare_warn_te%" == "" (
echo Check Result : UnSafe >> %filename% ) else (
echo Check Result : Safety >> %filename% ))

del %tempfile%-warning-te
del %tempfile%-warning-ti

echo ======== 5-12 LAN Manager ���� ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
echo ����� ���� : *Lan Manager ���� ���� ������ ���� ��Ʈ��ũ �α׿¿� ����� >> %filename%
echo Challenge/Response ���� ���������� �����ϸ� �� ������ Ŭ���̾�Ʈ�� ����ϴ� >> %filename%
echo ���� �������� ����, ����� ���� ���� ���� �� ������ ����ϴ� ���� ���ؿ� >> %filename%
echo ������ �ֱ� ������ ���پ����� ������ ���� �� ����ϴ� ���� ������ >> %filename%

echo. >> %filename%
echo ��ȣ : "LAN Manager " ���� ���� ��å�� "NTLMv2 ���丸 ����" �� �����Ǿ� �ִ� ���  >> %filename%
echo ��� : "LAN Manager " ���� ���� ��å�� "LM" �� "NTLM"������ �����Ǿ� �ִ� ��� >> %filename%

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

echo ======== 5-13 ���� ä�� ������ ������ ��ȣȭ �Ǵ�, ���� ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
echo ����� ���� : ���� ä�� ������ ������ ��ȣȭ �Ǵ�, ���� ������ ���� ������ �������� ������ >> %filename%
echo ��� ���� æ�� Ʈ������ �ּ� ���� �䱸 ������ �����ؾ��ϴ����� ���� >> %filename%
echo ���� Ʈ���� ������ ���� �ݺ� ���� �� ��Ÿ ������ ��Ʈ��ũ �������κ��� ��ȣ�ϱ� ����  >> %filename%
echo Windows ��ݿ����� NetLogon�� ���� ���� ä���̶�� ��� ä���� ����� ��ǻ�� �� ����� ������ ���� ������ ��. >> %filename%

echo. >> %filename%
echo ��ȣ : �Ʒ� 3���� ��å�� "���"���� �Ǿ� �ִ� ���  >> %filename%
echo ��� : �Ʒ� 3���� ��å�� "��� �� ��"���� �Ǿ� �ִ� ��� >> %filename%
echo * ������ ������ : ����ä�ε����͸� ������ ��ȣȭ �Ǵ� ����(�׻�) >> %filename%
echo * ������ ������ : ����ä�ε����͸� ������ ��ȣȭ(������ ���) >> %filename%
echo * ������ ������ : ����ä�ε����͸� ������ ����(������ ���) >> %filename%

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
echo ======== 5-14 ���� �� ���͸� ��ȣ ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
echo ����� ���� : NTFS ���� �ý����� ���� �� ��� ���ϰ� ���͸��� �����ǰ� >> %filename%
echo ��� ���� ������ �����ϰ� ���� ���� ��� �� ���������ν� ���� �ý��ۿ� ���� >> %filename%
echo ���� ��ȭ ACL( ) *FAT�� ���� ����� ���� >> %filename%

echo. >> %filename%
echo ��ȣ : NTFS ���� �ý����� ����ϴ� ���  >> %filename%
echo ��� : FAT���� �ý����� ����ϴ� ��� >> %filename%

echo list volume | diskpart >> %filename%
echo list volume | diskpart | findstr FAT > nul
echo. >> %filename%
if not errorlevel 1 echo Check Result : UnSafe >> %filename%
if errorlevel 1 echo Check Result : Safety >> %filename%

echo ======== 5-15 ��ǻ�� ���� ��ȣ �ִ� ��� �Ⱓ ======== >> %filename%
echo. >> %filename%
echo �׸��߿䵵 : �� >> %filename%
echo. >> %filename%
echo ����� ���� : NTFS ���� �ý����� ���� �� ��� ���ϰ� ���͸��� �����ǰ� >> %filename%
echo ��� ���� ������ �����ϰ� ���� ���� ��� �� ���������ν� ���� �ý��ۿ� ���� >> %filename%
echo ���� ��ȭ ACL( ) *FAT�� ���� ����� ���� >> %filename%

echo. >> %filename%
echo ��ȣ : "��ǻ�� ���� ��ȣ ���� ��� �� ��" ��å�� ������� ������,  >> %filename%
echo "��ǻ�� ���� ��ȣ �ִ� ��� �Ⱓ" ��å�� "90"��(0x5a)�� �����Ǿ� �ִ� ���  >> %filename%
echo ��� : ��å�� "���"���� �����Ǿ��ְų�, "90��"�� �����Ǿ� ���� ���� ��� >> %filename%

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
::DisablePasswordChange 0 ����
::MaximumPasswordAge 90 ����
del %tempfile%-dpc
del %tempfile%-mpa

:: #2018-7-4 Script the End 
cls
echo ##############################################
echo      Windows ����� ������ �Ϸ�Ǿ����ϴ�.
echo ##############################################
echo.
echo  �� report_w.html�� ���� �����ϰ� ����� Ȯ���Ҽ� �ֽ��ϴ�.
pause