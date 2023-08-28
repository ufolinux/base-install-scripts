VER=2023.1

PREFIX = /usr

BINPROGS = \
	base-chroot \
	genfstab \
	base-strap


BASH = bash

all: $(BINPROGS)

V_GEN = $(_v_GEN_$(V))
_v_GEN_ = $(_v_GEN_0)
_v_GEN_0 = @echo "  GEN     " $@;

edit = $(V_GEN) m4 -P $@.in >$@ && chmod go-w,+x $@

%: %.in common
	$(edit)

clean:
	$(RM) $(BINPROGS)

check: all
	@for f in $(BINPROGS); do bash -O extglob -n $$f; done
	@r=0; for t in test/test_*; do $(BASH) $$t || { echo $$t fail; r=1; }; done; exit $$r

install: all
	install -dm755 $(DESTDIR)$(PREFIX)/bin
	install -m755 $(BINPROGS) $(DESTDIR)$(PREFIX)/bin
	install -Dm644 completion/_baseinstallscripts.zsh $(DESTDIR)$(PREFIX)/share/zsh/site-functions/_baseinstallscripts
	cd completion; for comp in *.bash; do \
		install -Dm644 $$comp $(DESTDIR)$(PREFIX)/share/bash-completion/completions/$${comp%%.*}; \
	done;

.PHONY: all clean install uninstall
