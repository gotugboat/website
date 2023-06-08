all: asdf theme docs public

.PHONY: asdf
asdf:
	$(info ******************** installing tools ********************)
	asdf install

.PHONY: submodule
submodule:
ifeq (,$(wildcard themes/doks/assets))
	$(info ******************** downloading theme ********************)
	git submodule init && git submodule update
endif

.PHONY: theme
theme: submodule
	$(info ******************** preparing theme ********************)
	./scripts/fix-theme.sh && \
	cd themes/doks/ && \
	npm install && \
	rm -rf content

.PHONY: public
public: clean
	$(info ******************** building source ********************)
	hugo --gc --minify

.PHONY: clean
clean:
ifneq (,$(wildcard public))
	$(info ******************** cleaning up ********************)
	rm -rf public resources
endif

.PHONY: reset
reset: clean
	make docs\:clean
	$(info ******************** removing submodule ********************)
	git submodule deinit -f themes/doks

.PHONY: docs
docs:
	make docs\:generate

.PHONY: docs\:generate
docs\:generate:
	$(info ******************** generating docs ********************)
	./load-docs.sh

.PHONY: docs\:clean
docs\:clean:
ifneq (,$(wildcard generated))
	$(info ******************** cleaning up generated docs ********************)
	rm -rf generated repos content/docs
endif
