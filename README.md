awelchy
=======

1. `docker build -t awelchy .`
2. `docker run --rm -d -p8080:8080 awelchy:latest`
3. `curl -X POST http://localhost:9292/fuzzy-match -d '{"message":{"text":"my fault"}}'`
