#!/usr/bin/env python3

import sys
import os
sys.path.insert(0, os.path.join(os.getcwd(), 'osiris_scraper', 'scripts'))

# Test the SRE incident logic
from pm_actionitem_analyzer import PmActionItemAnalyzer

# Sample SRE incident response (same as in test)
sre_incident_response = {
    "key": "SRE-789",
    "fields": {
        "summary": "Incident summary",
        "status": {
            "name": "Resolved",
            "statusCategory": {"name": "Done"}
        },
        "labels": [],
        "assignee": {"displayName": "SRE User"},
        "reporter": {"displayName": "SRE Reporter"},
        "priority": {"name": "Critical"},
        "issuetype": {"name": "Incident"},
        "project": {"key": "SRE"},
        "created": "2024-01-01T09:00:00.000Z",
        "updated": "2024-01-01T11:00:00.000Z",
        "resolutiondate": "2024-01-01T11:00:00.000Z",
        "components": []
    }
}

# Test the logic directly
print("Testing SRE incident filtering logic...")

# Test 1: ignore_sre_incidents=True (should return None)
analyzer1 = PmActionItemAnalyzer('https://test.atlassian.net', 'user', 'token', ignore_sre_incidents=True)
print(f"Analyzer 1 - ignore_sre_incidents: {analyzer1.ignore_sre_incidents}")

# Test 2: ignore_sre_incidents=False (should return ticket info)
analyzer2 = PmActionItemAnalyzer('https://test.atlassian.net', 'user', 'token', ignore_sre_incidents=False)
print(f"Analyzer 2 - ignore_sre_incidents: {analyzer2.ignore_sre_incidents}")

# Simulate the logic from get_jira_ticket_info
fields = sre_incident_response.get('fields', {})
project_key = fields.get('project', {}).get('key', '')
issue_type = fields.get('issuetype', {}).get('name', '') if fields.get('issuetype') else ''

print(f"Project key: {project_key}")
print(f"Issue type: {issue_type}")
print(f"Issue type lower: {issue_type.lower()}")

# Test the filtering logic for analyzer1 (should be ignored)
should_ignore_1 = analyzer1.ignore_sre_incidents and project_key == 'SRE' and issue_type.lower() == 'incident'
print(f"Should ignore (analyzer1): {should_ignore_1}")

# Test the filtering logic for analyzer2 (should NOT be ignored)
should_ignore_2 = analyzer2.ignore_sre_incidents and project_key == 'SRE' and issue_type.lower() == 'incident'
print(f"Should ignore (analyzer2): {should_ignore_2}")

print("Logic test complete!") 