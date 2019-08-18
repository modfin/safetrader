.PHONY: live

live: api.js
	elm-live src/Main.elm -- --output=elm.js

api.js:
	wget https://apis.google.com/js/api.js
