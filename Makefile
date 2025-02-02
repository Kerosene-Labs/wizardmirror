dist:
	rm -r zig-out
	zig build
	mkdir zig-out/bin/lib
	cp /usr/lib/x86_64-linux-gnu/libSDL3* zig-out/bin/lib
	cp /usr/lib/x86_64-linux-gnu/libcurl* zig-out/bin/lib
	cp /usr/lib/x86_64-linux-gnu/libxml2* zig-out/bin/lib
	cp /usr/lib/x86_64-linux-gnu/librtmp* zig-out/bin/lib
	mkdir -p zig-out/bin/res/fonts
	cp -r /usr/share/fonts/truetype/open-sans zig-out/bin/res/fonts
	printf 'Note, you will need to write your own launcher script that modifies `LD_LIBRARY_PATH` to include the `lib` directory!' > zig-out/bin/README.md

install:
	rm -r /opt/wizardmirror
	mkdir /opt/wizardmirror
	cp -r zig-out/bin/* /opt/wizardmirror
	printf '#!/bin/bash\nLD_LIBRARY_PATH="/opt/wizardmirror/lib:$$LD_LIBRARY_PATH" /opt/wizardmirror/wizardmirror' > /opt/wizardmirror/launcher.sh
	chmod +x /opt/wizardmirror/launcher.sh
	rm /usr/bin/wizardmirror || true
	ln -s /opt/wizardmirror/launcher.sh /usr/bin/wizardmirror
	mkdir /home/$(SUDO_USER)/.config/wizardmirror || true
	cp config.example.json /home/$(SUDO_USER)/.config/wizardmirror/config.json
	chown -R $(SUDO_USER) ~/.config/wizardmirror
