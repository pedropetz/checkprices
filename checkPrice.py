#!/usr/bin/python3

import sys

from bs4 import BeautifulSoup

r = open(sys.argv[1], "r")
f = open(sys.argv[2], 'w')

contents = r.read()

soup = BeautifulSoup(contents, 'lxml')

sys.stdout = f

print(soup.prettify())

f.close()
