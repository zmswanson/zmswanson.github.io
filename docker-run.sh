# docker run --rm -v $(pwd):/srv/jekyll -p 4000:4000 -it jekyll/builder:pages bash
docker run --rm \
  -v "$(pwd)":/srv/jekyll \
  -p 4000:4000 \
  -it jekyll/builder:pages \
  jekyll serve --watch --drafts --host 0.0.0.0
