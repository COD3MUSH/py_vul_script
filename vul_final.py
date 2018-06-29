import subprocess
import os

#subprocess.call(["ls", "-l"])
os.system('./lib/linux.sh')

html_header = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title> REPORT </title>
    <link rel="stylesheet" href="css/bootstrap.css">
</head>
<body>
<br>
<div class="container">
<h2> Vulnerability Result </h2>
<div class="table-responsive">

<table id="visit-stat-table" class="table table-sorting table-striped table-hover datatable">
    <thead>
    <tr>
        <th>Vunerability Index / Title</th>
        <th>Check Result</th>
     </tr>
    </thead>
    <tbody>
'''

html_fotter = '''</tbody>
</table>
</div>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
<script type="text/javascript" src="js/bootstrap.js"></script>
</div>
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
    report.write("<h4> OS Version : "+osversion[i]+"</h4>")


#list(range(22))

for i in range(22):
    report.write("<tr>")
    report.write("<td>"+d_title[i]+"</td>")
    report.write("<td>"+d_check[i]+"</td>")
    report.write("</tr>")



report.write(html_fotter)
report.close()

os.remove('check')
os.remove('title')
os.remove('osversion')
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
