from jira import JIRA
import os

name = ["ed", "edd", "eddy"]
sys = ["s1", "s2", "s3"]
jira_url = os.getenv('JIRA_LINK')

for n in name:
    for s in sys:
        msg = 'Create access to ' + n + ' into systems ' + s + ' following the JR. profile'
        jira = JIRA(jira_url)
        new_issue = jira.create_issue(project='ITSAMPLE', summary=msg,
                                      description=msg, issuetype={'name': '[System] Incident'})
        print(new_issue)
