import requests
import json

j_usuario = "user.Jenkins"
j_pass = "pass.Jenkins"

r = requests.get('http://jenkins.url/api/json?pretty=true', auth=(j_usuario, j_pass))
b = r.json()

for n in b.get('jobs'):
    name = n.get('name')
    url = n.get('url')
    nx = url+"api/json?pretty=true"
    l = requests.get(nx, auth=(j_usuario, j_pass))
    d = l.json()
    for h in d.get('healthReport'):
        f = json.dumps(h)
        v = h.get('description')
        print("JOB_NAME: "+name+"\nJOB_URL: "+url+"\nJOB_URL_API: "+nx+"\nWORST_JOB: "+v+"\n")
