MATCH (u:User)-[:POSTS]-(t:Tweet)-[:MENTIONS]-(other:User)
WHERE id(u) < id(other)
MERGE (u)-[r:INTERACTS_WITH]->(other);

MATCH (u:User)-[:POSTS]-(t:Tweet)-[:RETWEETS]-(ot:Tweet)-[:MENTIONS]-(other:User)
WHERE id(u) < id(other)
MERGE (u)-[r:RT_MENTIONS]->(other);

MATCH (user1:User)-[:POSTS]->(t:Tweet)
WHERE t.text STARTS WITH 'RT @'
WITH user1, t, apoc.text.regexGroups(t.text, '^RT @([^@\s:]+)')[0][1] as word
MATCH (user2:User {screen_name: word})
WHERE id(user1) < id(user2)
WITH user1, t, word, user2
MERGE (user1)-[r:AMPLIFIES]->(user2)
WITH user1, t, user2
MATCH (t)-[:RETWEETS]->(ot:Tweet)
MERGE (user2)-[r2:POSTS]->(ot);

CALL gds.nodeSimilarity.stream({
  nodeProjection:'User',
  relationshipProjection:'INTERACTS_WITH'
})
YIELD node1, node2, similarity
WITH gds.util.asNode(node1).screen_name AS Person1, gds.util.asNode(node2).screen_name AS Person2, similarity
MATCH (u1:User {screen_name: Person1})
MATCH (u2:User {screen_name: Person2})
WHERE id(u2) < id(u1)
MERGE (u1)-[r:SIMILAR_TO {score: similarity}]->(u2);