module.exports = district => `
  SELECT ?election ?electionLabel ?person ?personLabel ?rank ?votes ?partyLabel ?representsLabel 
  WHERE {
    ?person p:P3602 ?candidacy.
    ?candidacy ps:P3602 ?election ; pq:P768 wd:${district} .
    OPTIONAL { ?election wdt:P585 ?date }
    OPTIONAL { ?candidacy pq:P1352 ?rank }
    OPTIONAL { ?candidacy pq:P1111 ?votes }
    OPTIONAL { ?candidacy pq:P102 ?party }
    OPTIONAL { ?candidacy pq:P1268 ?represents }
    SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
  }
  ORDER BY DESC(?date) DESC(?electionLabel) ?rank ?personLabel 
`
