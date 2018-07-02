@echo off

set filename=result.txt
set tempfile=temp
set tempfile1=temp1

echo ======== 1-1 Administrator ���� ���� ======== > %filename%
echo. >> %filename%

net localgroup Administrators >> %filename%

net localgroup Administrators > %tempfile%
FOR /F "tokens=1,2,3,4 skip=6" %%j IN (%tempfile%) Do echo %%j %%k %%l %%m >> admin-temp

findstr "Administrator" admin-temp
:: findstr "ã���ܾ�" ����

if errorlevel 1 echo Check Result : Safe >> %filename%
if not errorlevel  1 echo Check Result : UnSafe >> %filename%
del admin-temp

:: errorlevel�� ����� ����� ����Ǹ� 0
:: ������ ã���� ������ 1�� ��Ÿ����.

echo ======== 1-2 Guest ���� ���� ======== >> %filename%
echo. >> %filename%

net user guest | find "Ȱ�� ����" > %tempfile%

findstr "�ƴϿ�" %tempfile%

net user guest | find "Ȱ�� ����" >> %filename%

if errorlevel 1 echo  Check Result : UnSafe >> %filename%
if not errorlevel 1 echo Check Result : Safe >> %filename%


echo ======== 1-3 ���� ��� �Ӱ谪 ���� ======== >> %filename%
echo. >> %filename%

net accounts | find "��� �Ӱ谪" > %tempfile%
for /f "tokens=3" %%a in (%tempfile%) do set compare_val=%%a

net accounts | find "��� �Ӱ谪" >> %filename%


::if %compare_val%=="�ƴ�" echo Check Result : UnSafe >> %filename%
if not %compare_val% LEQ 5 echo Check Result : UnSafe >> %filename%
if not %compare_val% GTR 5 echo Check Result: Safe >> %filename%

echo ======== 1-4 ���� ��� �Ⱓ ���� ======== >> %filename%
echo. >> %filename%

net accounts | find "��� �Ⱓ" > %tempfile%
for /f "tokens=4" %%a in (%tempfile%) do set compare_val=%%a
if not %compare_val% LEQ 60 goto safe_val
if not %compare_val% GTR 60 goto unsafe_val
:: if not %compare_val% GEQ 60 echo Check Result : Unsafe >> %filename%

net accounts | find "��� ����" > %tempfile1%
for /f "tokens=5" %%a in (%tempfile1%) do set compare_val_1=%%a

net accounts | find "��� �Ⱓ" >> %filename%
net accounts | find "��� ����" >> %filename%

:safe_val
if not %compare_val1% LEQ 60 echo Check Result : Safe >> %filename%
goto 4_end

:unsafe_val
if not %compare_val1% GTR 60 echo Check Result : UnSafe >> %filename%


:4_end



pause