APP_VERSION = $(shell grep version package.json | grep -oE '[0-9\.]+')
APP_NAME = $(shell grep name package.json |/bin/grep -o '[^"]*",'|/bin/grep -o '[^",]*')

NW_VERSION = v0.12.3
NW_PLATFORM = linux-x64
COFFEE_TARGETS = $(shell find src/lib -type f -name "*.coffee"|sed 's,src/,,'|sed 's,\.coffee,\.js,')

SUPERVISOR = supervisor -e coffee,json,jade -x make -w src/lib,templates,package.json run
NWJS = ./deps/nwjs-$(NW_VERSION)-$(NW_PLATFORM)/nw --enable-transparent-visuals --disable-gpu

RM = rm -rfv
MKDIR = mkdir -p
ZIP = zip -r
COFFEE_COMPILE = coffee -c
TARXF = tar xmf

.PHONY all: deps lib


deps: deps/nwjs-$(NW_VERSION)-$(NW_PLATFORM).tar.gz deps/nwjs-$(NW_VERSION)-$(NW_PLATFORM)

deps/nwjs-$(NW_VERSION)-$(NW_PLATFORM): deps/nwjs-$(NW_VERSION)-$(NW_PLATFORM).tar.gz
	cd deps && $(TARXF) nwjs-$(NW_VERSION)-$(NW_PLATFORM).tar.gz

deps/nwjs-$(NW_VERSION)-$(NW_PLATFORM).tar.gz:
	mkdir -p deps
	cd deps && wget 'http://dl.nwjs.io/$(NW_VERSION)/nwjs-$(NW_VERSION)-$(NW_PLATFORM).tar.gz'

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

ZIP-exists:
	echo "Checking whether $(ZIP) is available"
	@which zip > /dev/null

dist: ZIP-exists lib deps
	$(ZIP) ../$(APP_NAME)-$(APP_VERSION).nw *

