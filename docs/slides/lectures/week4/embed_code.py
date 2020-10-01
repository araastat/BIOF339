import os, glob

html_files = glob.glob('*.html')
for h in html_files:
    txt = '<iframe src = "https://www.araastat.com/BIOF339/slides/lectures/week4/'+h+'" width="100%" height=600></iframe>'
    print(txt)
