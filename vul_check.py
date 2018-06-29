import subprocess
import os

#subprocess.call(["ls", "-l"])
os.system('./linux.sh')

html_header = '''<html>
<body>
<br>
<h1> Vulnerability Result </h1>
<table border=1>
<tr>
    <td> Index </td>
    <td> Check Result </td>
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

title.close()
check.close()
title = open("title",'r')
check = open("check",'r')

d_title = title.readlines()
d_check = check.readlines()

report = open("report.html",'w')
os_version = open("osversion",'r')
osversion = os_version.readlines()

report.write(html_header)

for i in range(1):
    report.write("<h3> OS Version : "+osversion[i]+"</h3>")
    

#list(range(22))

for i in range(22):
    report.write("<tr>")
    report.write("<td>"+d_title[i]+"</td>")
    report.write("<td>"+d_check[i]+"</td>")
    report.write("</tr>")



report.write(html_fotter)
report.close()

        #for rline in lines:
        #    if "Check" in rline:
        #        rline=rline.replace("Check Result : ","")
        #        check.write(rline)


        #for line in lines:
        #	if "========" in line:
        #		line = line.replace("========","")
        #        title.write(line)
        #        result.write("<tr>")
        #        result.write("<td>"+title[0]+"<td>")
        #        result.write("</tr>")

        #result.write(html_fotter)
        #f.close()
        #resul.close()
