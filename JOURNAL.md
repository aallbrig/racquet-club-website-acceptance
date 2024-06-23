# June 23rd, 2024
Back to this project! I'm glad I started writing `JOURNAL.md` and `SNIPPETS.md` files because it helps me hop back into the project.

Today I'm going to focus crawling the website and generating a report. The report should look something like...
```text
<page title>
  internal links:
    - link to <page title>
    - link to <page title>
    - link to <page title>
  external links:
    - link to <external url>
    - link to <external url>
    - link to <external url>
<page title>
  internal links:
    - link to <page title>
    - link to <page title>
    - link to <page title>
  external links:
    - link to <external url>
    - link to <external url>
    - link to <external url>
```
...Once I have this report in place then I can layer on applying business rules. I'll have to talk to my "client" at this stage.

---

# June 10th 2024
This project is meant to compare an actual website to a set of criteria, which form Acceptance Tests for the website.

The first thing we want to know about the website is that all of the current URLs point to an expected location.

My plan is to write a bash script and then consider writing a puppeteer based nodejs script to do more advanced operations, like generating screenshots of all the website pages.
