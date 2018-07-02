@echo off

set filename=result.txt
set tempfile=temp
set tempfile1=temp1

echo ======== 1-1 Administrator 계정 관리 ======== > %filename%
echo. >> %filename%

net localgroup Administrators >> %filename%

net localgroup Administrators > %tempfile%
FOR /F "tokens=1,2,3,4 skip=6" %%j IN (%tempfile%) Do echo %%j %%k %%l %%m >> admin-temp

findstr "Administrator" admin-temp
:: findstr "찾을단어" 파일

if errorlevel 1 echo Check Result : Safe >> %filename%
if not errorlevel  1 echo Check Result : UnSafe >> %filename%
del admin-temp

:: errorlevel은 명령이 제대로 실행되면 0
:: 파일을 찾을수 없으면 1로 나타난다.

echo ======== 1-2 Guest 계정 관리 ======== >> %filename%
echo. >> %filename%

net user guest | find "활성 계정" > %tempfile%

findstr "아니요" %tempfile%

net user guest | find "활성 계정" >> %filename%

if errorlevel 1 echo  Check Result : UnSafe >> %filename%
if not errorlevel 1 echo Check Result : Safe >> %filename%


echo ======== 1-3 계정 잠금 임계값 설정 ======== >> %filename%
echo. >> %filename%

net accounts | find "잠금 임계값" > %tempfile%
for /f "tokens=3" %%a in (%tempfile%) do set compare_val=%%a

net accounts | find "잠금 임계값" >> %filename%


::if %compare_val%=="아님" echo Check Result : UnSafe >> %filename%
if not %compare_val% LEQ 5 echo Check Result : UnSafe >> %filename%
if not %compare_val% GTR 5 echo Check Result: Safe >> %filename%

echo ======== 1-4 계정 잠금 기간 설정 ======== >> %filename%
echo. >> %filename%

net accounts | find "잠금 기간" > %tempfile%
for /f "tokens=4" %%a in (%tempfile%) do set compare_val=%%a
if not %compare_val% LEQ 60 goto safe_val
if not %compare_val% GTR 60 goto unsafe_val
:: if not %compare_val% GEQ 60 echo Check Result : Unsafe >> %filename%

net accounts | find "잠금 관찰" > %tempfile1%
for /f "tokens=5" %%a in (%tempfile1%) do set compare_val_1=%%a

net accounts | find "잠금 기간" >> %filename%
net accounts | find "잠금 관찰" >> %filename%

:safe_val
if not %compare_val1% LEQ 60 echo Check Result : Safe >> %filename%
goto 4_end

:unsafe_val
if not %compare_val1% GTR 60 echo Check Result : UnSafe >> %filename%


:4_end



pause