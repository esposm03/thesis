SHELL := /bin/bash
FONTTOOLS = uv run --with fonttools fonttools varLib.mutator
GOOGLEFONTS = https://github.com/google/fonts/raw/main

ALL_FONTS = $(shell echo \
	fonts/static/Merriweather-{3,4,5,6,7,8,9}00.ttf \
	fonts/static/SourceSerif4-{3,4,5,6,7,8,9}00.ttf \
	fonts/static/SourceSerif4-Italic-{3,4,5,6,7,8,9}00.ttf )

all: $(ALL_FONTS)
	# this uses typst v0.13.1.
	# if needed, a compiled x86_64 Linux executable can be found at "vendor/typst".
	typst compile --ignore-system-fonts --font-path fonts/static/ slides.typ
	typst compile --ignore-system-fonts --font-path fonts/static/ thesis.typ --pdf-standard a-2b
	typst compile --ignore-system-fonts --font-path fonts/static/ printable-thesis.typ

clean:
	rm -r fonts

# Download variable fonts

fonts/variable/Merriweather[opsz,wdth,wght].ttf:
	wget -P fonts/variable '$(GOOGLEFONTS)/ofl/merriweather/Merriweather%5Bopsz,wdth,wght%5D.ttf'
fonts/variable/Merriweather-Italic[opsz,wdth,wght].ttf:
	wget -P fonts/variable '$(GOOGLEFONTS)/ofl/merriweather/Merriweather-Italic%5Bopsz,wdth,wght%5D.ttf'

fonts/variable/SourceSerif4[opsz,wght].ttf:
	wget -P fonts/variable '$(GOOGLEFONTS)/ofl/sourceserif4/SourceSerif4%5Bopsz,wght%5D.ttf'
fonts/variable/SourceSerif4-Italic[opsz,wght].ttf:
	wget -P fonts/variable '$(GOOGLEFONTS)/ofl/sourceserif4/SourceSerif4-Italic%5Bopsz,wght%5D.ttf'

# Make static fonts

fonts/static/Merriweather-%.ttf: fonts/variable/Merriweather[opsz,wdth,wght].ttf
	mkdir -p fonts/static
	$(FONTTOOLS) '$<' wght=$* wdth=105 -o $@

fonts/static/SourceSerif4-Italic-%.ttf: fonts/variable/SourceSerif4-Italic[opsz,wght].ttf
	mkdir -p fonts/static
	$(FONTTOOLS) $< wght=$* -o $@

fonts/static/SourceSerif4-%.ttf: fonts/variable/SourceSerif4[opsz,wght].ttf
	mkdir -p fonts/static
	$(FONTTOOLS) $< wght=$* -o $@

# Custom build of Iosevka

fonts/static/IosevkaThesis-Regular.ttf fonts/static/IosevkaThesis-Italic.ttf: iosevka.toml
	if cd fonts/Iosevka; then git pull; else git clone --depth 1 https://github.com/be5invis/Iosevka.git fonts/Iosevka; fi

	cp iosevka.toml fonts/Iosevka/private-build-plans.toml
	cd fonts/Iosevka && npm install
	cd fonts/Iosevka && npm run build -- ttf::IosevkaThesis
	
	mkdir -p fonts/static
	cp fonts/Iosevka/dist/IosevkaThesis/TTF/IosevkaThesis-Regular.ttf fonts/static
	cp fonts/Iosevka/dist/IosevkaThesis/TTF/IosevkaThesis-Italic.ttf fonts/static
