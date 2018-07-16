#-*- conding:UTF-8 -*-

import os
os.system('lib\window.bat')

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
        <th>Vunerability Title</th>
        <th>Check Result</th>
     </tr>
    </thead>
    <tbody>
'''

html_fotter = '''</tbody>
</table>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
<script type="text/javascript" src="lib/js/bootstrap.js"></script>
</body>
</html>'''


window_result = open("result_w.txt",'r')
lines = window_result.readlines()
title = open("title_w",'w')
check = open("check_w",'w')

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

title = open("title_w",'r')
check = open("check_w",'r')

d_title = title.readlines()
d_check = check.readlines()
c_check = open("c_check_w",'w')


for line in d_check:
    if "UnSafe" in line:
        line = line.replace("UnSafe", "<td style='color:red'>UnSafe")
        c_check.write(line)
    else:
        line = line.replace("Safety", "<td>Safety")
        c_check.write(line)

c_check.close()
check.close()

check = open("c_check_w",'r')
d_check = check.readlines()

report = open("report_w.html",'w',encoding="utf-8")
os_version = open("osversion_w",'r')
osversion = os_version.readlines()

report.write(html_header)

for i in range(1):
    report.write("<h4>"+osversion[i]+"</h4>")

for i in range(18):
    if i == 0 :
        report.write("<tr><td colspan='3' align='center' bgcolor='darksalmon'>")
        report.write("1 계정 관리 </td></tr>")

    if i == 5 :
        report.write("<tr><td colspan='3' align='center' bgcolor='aquamarine'>")
        report.write("2 서비스 관리 </td></tr>")

    if i == 11 :
        report.write("<tr><td colspan='3' align='center' bgcolor='lightskyblue'>")
        report.write("3 패치 관리 </td></tr>")

    if i == 12 :
        report.write("<tr><td colspan='3' align='center' bgcolor='lightgrey'>")
        report.write("4 로그 관리 </td></tr>")

    if i == 15 :
        report.write("<tr><td colspan='3' align='center' bgcolor='#3c64bf'>")
        report.write("5 보안 관리 </td></tr>")

    report.write("<tr>")
    report.write("<td>"+d_title[i]+"</td>")
    report.write(""+ d_check[i] + "</td>")
    report.write("</tr>")


#    report.write("<td>"+d_check[i]+"</td>")
#    report.write("</tr>")

report.write(html_fotter)
check.close()
title.close()
os_version.close()
report.close()

os.remove('c_check_w')
os.remove('check_w')
os.remove('title_w')
os.remove('osversion_w')
# os.remove를 쓰기위해 open하고 read 한 파일을 close로 닫아줘야한다.

