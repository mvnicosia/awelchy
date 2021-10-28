awelchy
=======

1. `docker build -t awelchy .`
2. `docker run --rm -d -p9292:9292 awelchy:latest`
3. `curl -X POST http://localhost:9292/fuzzy-match -d "help"`
