awelchy
=======

1. `docker build -t awelchy . && docker run --rm -p8080:8080 awelchy:latest`
2. `curl -X POST https://awelchy.herokuapp.com/fuzzy-match -H 'Content-Type: application/x-www-form-urlencoded' -d 'text=my+fault'` 
3. `docker container stop $(docker container list | grep "awelchy" | awk '{print $1}')`
