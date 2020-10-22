import sys, json, os
from jericho import *

print("===== Jericho Interface =====")
ext = sys.argv[1]
js = None
cfg = None
env = None
quicksave = None
with open(ext+"payload.json", 'r') as f: js = json.loads(f.read())
with open(ext+"data.json", 'r') as f: cfg = json.loads(f.read())

def export():
    with open(ext+"ext.json", 'w+') as f:
        outp = {"won": env.victory(), "signed": js["signed"]}
        f.write(json.dumps(outp))    
while True:
    s = input("> ");

    if s.startswith(".run"):
        g = ' '.join(s.split(" ")[1:])
        env = FrotzEnv(os.path.expanduser(cfg["zmachine"]["directory"])+g)
        initial_s, info = env.reset()
        print(initial_s)

    elif s == ".roms":
        
    elif s == ".qs":
        quicksave = env.get_state()

    elif s == ".ql":
        env.set_state(quicksave)
    
    elif s == ".load":
        pass

    elif s == ".save":
        pass
    
    elif s == ".ls":
        print('Recognized Vocabulary Words', list(env.get_dictionary()))
        
    elif s == ".q" or s == ".quit":
        if(input("Quit? (y/n)\n> ") != "y"):
            continue
        if(env != None): env.close()
        export()
        break;
    else:
        if env == None:
            print("No machine loaded.")
            continue
        observation, reward, done, info = env.step(s)

        print( f"SCORE: {info['score']}/{env.get_max_score()} - MOVES {info['moves']}\n{observation}" )
        if env.game_over():
            export()
            env.close()
            break
        if(env.victory()):
            export()
            env.close()
            break
