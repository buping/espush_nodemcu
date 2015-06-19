#!/usr/bin/env python
# encoding: utf-8
'''
Created on 2015年6月15日

@author: Sunday
'''
 
from __future__ import unicode_literals
from __future__ import print_function
 
import sys
import time
import serial
import threading
 
 
def t2(ser):
    print('线程启动')
    while 1:
        print(ser.readline())
 
 
def main():
    if len(sys.argv) < 3:
        print("参数错误，请接端口，文件名 ")
        return sys.exit(1)
    fname = sys.argv[2]
    ser = serial.Serial(sys.argv[1])
    th = threading.Thread(target=t2, args=(ser,))
    th.start()
    #  file.open("hello.lua","w+")
    line_header = b"file.open('" + fname + b"', 'w+')"
    ser.write(line_header)
    for line in open(fname):
        time.sleep(0.1)
        line = line.strip()
        line += b'\\r\\n'
        line = line.replace(b'"', b'\\"')
        line = line.replace(b"'", b"\\'")
        line = b"file.writeline('" + line + b"')\r\n"
        for w in line:
            ser.write(w)
            time.sleep(0.02)
 
if __name__ == '__main__':
    main()

