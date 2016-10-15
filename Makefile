all:
	make elm && make css

elm:
	elm make Main.elm --output build/main.js

css:
	sass scss/style.scss build/style.css