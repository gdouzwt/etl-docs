#!/usr/bin/env bash
bundle exec jekyll clean
bundle exec jekyll build
cd ./_site
zip -r good.zip .
scp good.zip seedland_test:/data/www-html/
curl -H "Content-Type: application/json" https://test-hr-srpt.seedland.cc/hooks/etl-update
cd ..
