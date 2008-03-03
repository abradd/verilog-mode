S=/home/mac/development/www.verilog.com/src/
D=$(S)data
F=/home/mac/external_webpage/src/verilog.com/ftp
# the directory where the .elc files will be installed
XEMACS  = xemacs
XEMACS_DEST = /usr/local/lib/xemacs/xemacs-packages/lisp/prog-modes/
EMACS   = emacs
EMACS_DEST = /usr/share/emacs/site-lisp/
ELC	= -batch -q -l verilog-mode.el -f batch-byte-compile
CVS_GNU = cvs -d:pserver:anonymous@cvs.sv.gnu.org:/sources/emacs

release : dirs install
install : dirs test $(D)/mmencoded_verilog-mode $(D)/emacs-version.h\
	$(S)ChangeLog.txt email $(S)bits/verilog-mode.el local \
#	ftp  
	@echo Installation up to date
dirs:	
	@mkdir -p .timestamps
test:	.timestamps/test
.timestamps/test: x/verilog-mode.elc e/verilog-mode.elc mmencoded_verilog-mode verilog.info 0test.el
	$(MAKE) test_batch
	$(MAKE) test_emacs
	$(MAKE) test_xemacs
	@touch $@

test_emacs:
	@echo
	@echo == test_emacs
	$(EMACS)  --batch -q -l e/verilog-mode.elc -l 0test.el
test_xemacs:
	@echo
	@echo == test_xemacs
	$(XEMACS) --batch -q -l x/verilog-mode.elc -l 0test.el
test_batch:
	@echo
	@echo == test_batch
	./batch_test.pl

local:	.timestamps/local
.timestamps/local:  verilog-mode.el
	cp verilog-mode.el $(XEMACS_DEST)verilog-mode.el
	$(XEMACS) $(ELC) $(XEMACS_DEST)verilog-mode.el
	cp verilog-mode.el $(EMACS_DEST)verilog-mode.el
	$(EMACS) $(ELC) $(EMACS_DEST)verilog-mode.el
	@touch $@

ftp:	.timestamps/ftp
.timestamps/ftp:	$(F) mmencoded_verilog-mode verilog-mode.el README
	cp mmencoded_verilog-mode $(F)
	cp verilog-mode.el $(F)
	cp README $(F)/.message
	@touch $@

$(F):
	mkdir $(F)

ChangeLog.txt mmencoded_verilog-mode emacs-version.h : make_log.pl verilog-mode.el README
	./make_log.pl	

email:	.timestamps/email
.timestamps/email: mmencoded_verilog-mode
	./make_mail.pl
	@touch $@

$(D)/mmencoded_verilog-mode : mmencoded_verilog-mode
	cp $? $@
$(D)/emacs-version.h : emacs-version.h
	cp $? $@
	touch $(S)verilog-mode.html
$(S)ChangeLog.txt : ChangeLog.txt
	cp $? $@
$(S)bits/verilog-mode.el : verilog-mode.el
	cp $? $@

x/verilog-mode.elc : verilog-mode.el
	rm -rf x
	mkdir x
	cp verilog-mode.el x/verilog-mode.el
	$(XEMACS) $(ELC) x/verilog-mode.el

e/verilog-mode.elc : verilog-mode.el
	-rm -rf e
	-mkdir e
	cp verilog-mode.el e/verilog-mode.el
	$(EMACS) $(ELC) e/verilog-mode.el

verilog.info : verilog.texinfo
	makeinfo verilog.texinfo > verilog.info

######################################################################
# GNU CVS version

.PHONY: gnu-update gnu-update-22 gnu-update-head
gnu-update: gnu-update-22 gnu-update-head
gnu-update-22: gnu22
	cd gnu22   && $(CVS_GNU) co -rEMACS_22_BASE emacs/lisp/progmodes/verilog-mode.el
gnu-update-head: gnuhead
	cd gnuhead && $(CVS_GNU) co -rHEAD          emacs/lisp/progmodes/verilog-mode.el

gnu22:
	mkdir -p $@
gnuhead:
	mkdir -p $@

.PHONY: gnu-diff-head gnu-diff-22 gnu-diff
gnu-diff: gnu-diff-head

gnu-diff-head: gnu-update-head verilog-mode-tognu.el
	diff -c verilog-mode-tognu.el gnuhead/emacs/lisp/progmodes/verilog-mode.el

gnu-diff-22: gnu-update-22 verilog-mode-tognu.el
	diff -c gnu22/emacs/lisp/progmodes/verilog-mode.el verilog-mode-tognu.el 
gnu-diff-each: gnu-update-22 gnu-update-head
	diff -c gnuhead/emacs/lisp/progmodes/verilog-mode.el gnu22/emacs/lisp/progmodes/verilog-mode.el

verilog-mode-tognu.el: verilog-mode.el Makefile
	cat verilog-mode.el \
	 | sed 's/ *\$$Id:.*//g' \
	 | sed 's/(substring.*\$$\$$Revision: \([0-9]*\).*$$/"\1"/g' \
	 | sed 's/(substring.*\$$\$$Date: \(....-..-..\).*).*$$/"\1-GNU"/g' \
	 | sed 's/verilog-mode-release-emacs nil/verilog-mode-release-emacs t/g' \
	 > verilog-mode-tognu.el
