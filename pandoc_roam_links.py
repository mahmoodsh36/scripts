#!/usr/bin/env python3.10

# source: https://www.amoradi.org/20210730173543.html

import panflute as pf
import sqlite3
import pathlib
import sys
import os
import pprint
import urllib

#### CHANGE THESE ####
ORG_ROAM_DB_PATH = "~/.emacs.d/org-roam.db"
#### END CHANGE ####

db = None

def sanitize_link(elem, doc):
    if type(elem) != pf.Link:
        return None

    if not elem.url.startswith("id:"):
        return None

    file_id = elem.url.split(":")[1]

    cur = db.cursor()
    cur.execute(f"select id, file, title from nodes where id = '\"{file_id}\"';")
    data = cur.fetchone()

    # data contains string that are quoted, we need to remove the quotes
    if not data: # if id doesnt exist in database
        return None
    file_id = data[0][1:-1]
    file_name = urllib.parse.quote(os.path.splitext(os.path.basename(data[1][1:-1]))[0])

    elem.url = f"{file_name}.html"
    return elem

def main(doc=None):
    return pf.run_filter(sanitize_link, doc=doc)

if __name__ == "__main__":
    db = sqlite3.connect(os.path.expanduser(ORG_ROAM_DB_PATH))
    main()