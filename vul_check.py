import subprocess
import os

#subprocess.call(["ls", "-l"])
os.system('./linux.sh')

html_header = '''<html>
<body>
<br>
<h1> RESULT TITLE </h1>
<table border=1>
<tr>
    <td> test1 </td>
    <td> test2 </td>
</tr>
'''

html_fotter = '''</tr>
</table>
</body>
</html>'''


linux_result = open("result.txt",'r')
lines = linux_result.readlines()
title = open("title",'w')
check = open("check",'w')

for line in lines:
    if "========" in line:
        line = line.replace("========","")
        title.write(line)

for line in lines:
    if "Check" in line:
        line = line.replace("Check Result : ","")
        check.write(line)
