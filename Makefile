TARGET?=production

.PHONY: build-theme
build-theme: themes/bilberry-hugo/static/theme.css

themes/bilberry-hugo/static/theme.css: $(wildcard themes/bilberry-hugo/assets/sass/*.scss)
	cd themes/bilberry-hugo && \
		npm install && \
		npm run $(TARGET)
	touch $@

themes/bilberry-hugo/%: themes/bilberry-hugo.override/%
	cp $< $@

.PHONY: touch-override
touch-override:
	find themes/bilberry-hugo.override/ -type f -exec touch {} \;

