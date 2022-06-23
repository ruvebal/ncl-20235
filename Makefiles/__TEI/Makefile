# My dissertation Makefile
# Something like my meta-dissertation
# by ruvebal@crea-comm.net
# This is the source core, private until publishing
# April, 2014


include Makefile.conf

# ---------------------------------------------------------------------------------- #
# Functions
# ---------------------------------------------------------------------------------- #

myMkdir = $(shell if [ ! -d $1 ]; then mkdir -p $1; fi)


# myRsync = $(shell rsync 						\
# 		-Larv 									\
# 		--exclude '*~' 							\
# 		--exclude '*.sh' 						\
# 		--exclude '.ht*' 						\
# 		--exclude '*#*' 						\
# 		$1/										\
# 		$2 )


mySaxon = $(shell xmllint						\
		--xinclude 								\
		--format  								\
		--nsclean								\
		--noblanks								\
		$1										\
	|							 				\
	java -jar java/saxon9he.jar		  			\
		-ext:on 								\
		-strip:all								\
		-s:-									\
		-o:$2									\
		-xsl:$3									\
		-xi:on 									\
		\!indent=yes)


# ---------------------------------------------------------------------------------- #
# Variables
# ---------------------------------------------------------------------------------- #
# The sources
corpus := sources/corpus.tei
# The outputs
html5 := build/html5
files := build/files
#
odt :=	build/files/ruvebal-dissertation.odt
# htdocs
htdocs= build/htdocs
www := $(DOC-ROOT)$(BASEDIR)
teic := stylesheet/teic

#www := /var/www/crea-comm.net/ruvebal/scholar/dissertation

# --------------------------------------------------------------------------------- #
# Next come fogery but usefull targets 
# --------------------------------------------------------------------------------- #

.PHONY: all clean html5 files odt www teic 
.PHONY: $(www) $(htdocs) $(htdocs)/files $(teic)
all: html5 files www 

html5: $(html5)
files: $(files)
odt: $(odt)
www: $(www) 
htdocs: $(htdocs)

clean:
	rm -f -r ./build/files ./build/html5 ./build/odt ./build/htdocs
backup:
	rsync		 									\
		-Larve "ssh -p 9999"						\
		./											\
		satan.crea-comm.net:~/domos/scholar/dissertation

# --------------------------------------------------------------------------------- #
# TEI stylesheets already forked previously:
# cd stylesheet
# git clone https://github.com/TEIC/Stylesheets.git teic
# --------------------------------------------------------------------------------- #
teic: $(teic)
$(teic):
	cd $(@) && git pull origin

# --------------------------------------------------------------------------------- #
# Web compilation
# --------------------------------------------------------------------------------- #
$(www): $(htdocs) $(htdocs)/files
	rsync		 								\
		-Larv 									\
		--exclude '*~' 							\
		--exclude '*.sh' 						\
		--exclude '.ht*' 						\
		--exclude '*#*' 						\
		$</										\
		$@

$(htdocs): $(html5)
	rsync		 								\
		-Larv 									\
		--exclude '*~' 							\
		--exclude '*.sh' 						\
		--exclude '.ht*' 						\
		--exclude '*#*' 						\
		$</										\
		$@

$(htdocs)/files: $(files) 
	rsync		 								\
		-Larv 									\
		--exclude '*~' 							\
		--exclude '*.sh' 						\
		--exclude '.ht*' 						\
		--exclude '*#*' 						\
		$</										\
		$@

# ---------------------------------------------------------------------------------- #
# The binaries, that include the ODT and will the PDF ePUB and so on
# ---------------------------------------------------------------------------------- #
$(files): build $(odt)
# ---------------------------------------------------------------------------------- #

# The odt builder
TEMPLATE ?=\

build/files/ruvebal-dissertation.odt: TEMPLATE=stylesheet/myTEI/profiles/default/odt/template.odt.dir
build/files/ruvebal-dissertation.odt: build/odt/content.xml $(TEMPLATE)
	$(call myMkdir,$(dir $@))
#	unzip -d $(shell dirname $<) $(TEMPLATE)
	rsync -Larv $(TEMPLATE)/ $(shell dirname $<) 
	cd $(shell dirname $<) && zip -0 -X ../../$@ mimetype && zip -r ../../$@ * -x mimetype
#	cd $(shell dirname $<) && zip -r ../../$@  mimetype .

build/odt/content.xml: XSL=stylesheet/odt/wrapper.xsl
#build/odt/content.xml: XSL=stylesheet/teic/profiles/default/odt/to.xsl
build/odt/content.xml: $(corpus)
	$(call mySaxon,$<,$@,$(XSL))

# ---------------------------------------------------------------------------------- #
# The html5 builder
# ---------------------------------------------------------------------------------- #
XSL ?=\

$(html5): build $(html5)/index/index.html $(html5)/corpus/index.html $(html5)/odt/index.php

$(html5)/odt/index.php: stylesheet/html5/odt/index.html
	$(call myMkdir,$(dir $@))
	cp $< $@

$(html5)/corpus/index.html: XSL=stylesheet/html5/wrapper.xsl
$(html5)/corpus/index.html: $(corpus)
	$(call mySaxon,$<,$@,$(XSL))

$(html5)/index/index.html: XSL=stylesheet/html5/index.xsl
$(html5)/index/index.html: $(corpus)
	$(call mySaxon,$<,$@,$(XSL))


# ---------------------------------------------------------------------------------- #

stylesheet/%:
	$(shell if [ ! -f $@ ]; then echo "Does not exist resource $@" && exit 1; fi)
sources/%:
	$(shell if [ ! -f $@ ]; then echo "Does not exist resource $@" && exit 1; fi)
build/%:
	$(call myMkdir,$(dir $@))

