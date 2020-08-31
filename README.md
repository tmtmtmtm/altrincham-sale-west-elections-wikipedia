
The code and queries etc here are unlikely to be updated as my process
evolves. Later repos will likely have progressively different approaches
and more elaborate tooling, as my habit is to try to improve at least
one part of the process each time around.

---------

Step 1: Configure config.json
=============================

All the relevant metadata lives in config.json: ideally nothing will
need tweaked after this. We need to be careful here to get the history
of Wikidata IDs for the constituency correct.

```sh
git add config.json && git commit -m "add configuration"
```

Step 2: Scrape the results
==========================

```sh
bundle exec ruby scraper.rb config.json | tee wikipedia.csv &&
  git add wikipedia.csv && git commit -m "Initial wikipedia.csv"
```

Step 3: Check for missing party IDs
===================================

```sh
xsv search -v -s party 'Q' wikipedia.csv
```

Nothing missing.

Step 4: Check for missing election IDs
=====================================

```sh
xsv search -v -s election 'Q' wikipedia.csv | xsv select electionLabel | uniq
```

Nothing missing.

Step 5: Generate possible missing person IDs
============================================

```sh
xsv search -v -s id 'Q' wikipedia.csv | xsv select name | tail +2 |
  sed -e 's/^/"/' -e 's/$/"@en/' | paste -s - |
  xargs -0 wd sparql find-candidates.js |
  jq -r '.[] | [.name, .item.value, .election.label, .constituency.label, .party.label] | @csv' |
  tee candidates.csv &&
  git add candidates.csv && git commit -m "initial candidates.csv"
```

Step 6: Remove unwanted candidacies from list
=============================================

Look for anyone mis-reconciled, and ensure that each person only exists
once, then re-commit:

```sh
git add candidates.csv && git commit -m "Remove unwanted reconciliations"
```

Step 7: Combine Those and generate QuickStatements commands
===========================================================

```sh
xsv join -n --left 2 wikipedia.csv 1 candidates.csv | xsv select '10,1-8' | sed $'1i\\\nfoundid' | tee combo.csv
bundle exec ruby generate-qs.rb config.json | tee commands.qs
git add combo.csv commands.qs ; git commit -m "Initial combo.csv and commands.qs"
pbcopy < commands.qs
```

Then sent to QuickStatements as https://tools.wmflabs.org/editgroups/b/QSv2T/1598863056368
