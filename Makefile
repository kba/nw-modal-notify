NW_VERSION = v0.12.3
COFFEE_TARGETS = $(shell find src/lib -type f -name "*.coffee"|sed 's,src/,,'|sed 's,\.coffee,\.js,')
SUPERVISOR = supervisor -e coffee,json,jade -x make -w src/lib,templates,package.json run
NWJS = ./dist/nwjs-$(NW_VERSION)-linux-x64/nw --enable-transparent-visuals --disable-gpu

RM = rm -rfv
MKDIR = mkdir -p
COFFEE_COMPILE = coffee -c

.PHONY all: dist lib

dist: dist/nwjs-$(NW_VERSION)-linux-x64.tar.gz
	cd dist && tar xf nwjs-$(NW_VERSION)-linux-x64.tar.gz

dist/nwjs-$(NW_VERSION)-linux-x64.tar.gz:
	mkdir -p dist
	cd dist && wget 'http://dl.nwjs.io/$(NW_VERSION)/nwjs-$(NW_VERSION)-linux-x64.tar.gz'

lib: ${COFFEE_TARGETS}

lib/%.js: src/lib/%.coffee
	@$(MKDIR) $(dir $@)
	$(COFFEE_COMPILE) -p -b $^ > $@

clean:
	$(RM) lib

run: lib
	$(NWJS) .

dev-run: lib
	$(SUPERVISOR)

