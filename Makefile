# Define the default target when running just 'make'
.DEFAULT_GOAL := serve

# Declare phony targets to prevent conflicts with files of the same name
.PHONY: install serve build clean help

## install   : Install Ruby dependencies via Bundler
install:
	bundle install

## serve     : Start Jekyll and automatically open the site in Firefox
serve:
	@echo "Launching Firefox in the background..."
	@(while ! curl -s -o /dev/null http://localhost:4000; do sleep 0.5; done; open -a "Firefox" http://localhost:4000 || firefox http://localhost:4000) &
	bundle exec jekyll serve --livereload --drafts

## build     : Build the static site for production
build:
	JEKYLL_ENV=production bundle exec jekyll build

## clean     : Remove Jekyll cache and the generated site directory
clean:
	bundle exec jekyll clean

## help      : Display available tasks
help:
	@echo "Available tasks:"
	@sed -n 's/^##//p' $(MAKEFILE_LIST)

