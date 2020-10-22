import sys, json

print("===== TEST GAME =====")
ext = sys.argv[1]
js = None
print(f" Ext Dir {ext}")
with open(ext+"payload.json", 'r') as f:
    js = json.loads(f.read())

while True:
    s = input("TESTSH > ");
    print(s)
    if s == "q":
        with open(ext+"ext.json", 'w+') as f:
            outp = {"won": True, "signed": js["signed"]}
            f.write(json.dumps(outp))
        break;
