import subprocess
import os

#subprocess.call(["ls", "-l"])
os.system('./lib/linux.sh')






html_header = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title> REPORT </title>
    <link rel="stylesheet" href="lib/css/bootstrap.css">
</head>
<body>
<br>
<div class="container">
<h2> Vulnerability Result </h2>
<div class="table-responsive">
<table id="visit-stat-table" class="table table-sorting table-striped table-hover datatable">
    <thead>
    <tr>
        <th width="20">Index</th>
        <th>Vunerability Title</th>
        <th>Check Result</th>
     </tr>
    </thead>
    <tbody>
'''

html_fotter = '''</tbody>
</table>
</div>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
<script type="text/javascript" src="lib/js/bootstrap.js"></script>
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
index = open("index",'r')

d_title = title.readlines()
d_check = check.readlines()
d_index = index.readlines()

report = open("report.html",'w')
os_version = open("osversion",'r')
osversion = os_version.readlines()

report.write(html_header)

for i in range(1):
    report.write("<h4> OS Version : "+osversion[i]+"</h4>")


#list(range(22))

for i in range(22):
    if i == 0 :
        report.write("<tr><td colspan='3' align='center' bgcolor='darksalmon'>")
        report.write("1 Acouunts Management</td></tr>")

    if i == 5 :
        report.write("<tr><td colspan='3' align='center' bgcolor='aquamarine'>")
        report.write("2 File & Directories Management</td></tr>")

    if i == 15 :
        report.write("<tr><td colspan='3' align='center' bgcolor='cornflowerblue'>")
        report.write("3 Service Management </td></tr>")

    report.write("<tr>")
    report.write("<td>"+d_index[i]+"</td>")
    report.write("<td>"+d_title[i]+"</td>")
    report.write("<td>"+d_check[i]+"</td>")
    report.write("</tr>")

report.write(html_fotter)
report.close()

os.remove('check')
os.remove('title')
os.remove('index')
os.remove('osversion')