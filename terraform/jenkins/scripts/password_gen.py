import bcrypt
import os
import sys


plaintext_pwd = "hxqj_aC2DFb8Iv4H0NAOl5TI8as"
"""if not sys.argv[1]:
  sys.exit(10)
plaintext_pwd = sys.argv[1]"""
encrypted_pwd = bcrypt.hashpw(plaintext_pwd.encode('utf-8'), bcrypt.gensalt(rounds=10, prefix=b"2a"))
isCorrect = bcrypt.checkpw(plaintext_pwd.encode('utf-8'), encrypted_pwd)

if not isCorrect:
  sys.exit(20);

print(encrypted_pwd.decode("utf-8"))
