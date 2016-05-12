import imaplib
import sys
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect(("gmail.com",80))
ip = s.getsockname()[0]
s.close()

M = imaplib.IMAP4_SSL(ip, 993)
resp, data = M.login("eyeos@open365.io", "eyeos")
M.logout()
if resp == "OK":
    sys.exit(0)
else:
    sys.exit(1)
