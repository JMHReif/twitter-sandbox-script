MATCH (u:User)-[:POSTS]-(t:Tweet)-[:MENTIONS]-(other:User)
WHERE elementId(u) < elementId(other)
MERGE (u)-[r:INTERACTS_WITH]->(other);

MATCH (u:User)-[:POSTS]-(t:Tweet)-[:RETWEETS]-(ot:Tweet)-[:MENTIONS]-(other:User)
WHERE elementId(u) < elementId(other)
MERGE (u)-[r:RT_MENTIONS]->(other);

MATCH (user1:User)-[:POSTS]->(t:Tweet)
WHERE t.text STARTS WITH 'RT @'
WITH user1, t, apoc.text.regexGroups(t.text, '^RT @([^@\s:]+)')[0][1] as word
MATCH (user2:User {screen_name: word})
WHERE elementId(user1) < elementId(user2)
WITH user1, t, word, user2
MERGE (user1)-[r:AMPLIFIES]->(user2)
WITH user1, t, user2
MATCH (t)-[:RETWEETS]->(ot:Tweet)
MERGE (user2)-[r2:POSTS]->(ot);

MATCH (source:User)-[r:INTERACTS_WITH]->(target:User)
WITH gds.graph.project('myXGraph', source, target) AS g
RETURN g.graphName AS graph, g.nodeCount AS nodes, g.relationshipCount AS rels;

CALL gds.nodeSimilarity.stream('myXGraph')
YIELD node1, node2, similarity
WITH gds.util.asNode(node1).screen_name AS Person1, gds.util.asNode(node2).screen_name AS Person2, similarity
MATCH (u1:User {screen_name: Person1})
MATCH (u2:User {screen_name: Person2})
WHERE elementId(u2) < elementId(u1)
MERGE (u1)-[r:SIMILAR_TO {score: similarity}]->(u2);