## 
## <img align=right width=400 src='etc/img/about.jpg'>
## 
## # About.lua
##
## Extract stats from csv file (assumes row1 has column names).
##

-include ../etc/Makefile

about.md: ../4readme/readme.lua about.lua ## update readme
	gawk 'sub(/^## /,"")' Makefile > $@
	(printf "\n\`\`\`css\n"; lua about.lua -h ; printf "\`\`\`\n") >> $@
	lua $< about.lua >> $@

# changes to 3 cols and 101 chars/line
~/tmp/%.pdf: %.lua  ## .lua ==> .pdf
	mkdir -p ~/tmp
	echo "pdf-ing $@ ... "
	a2ps                 \
		-BR                 \
		--chars-per-line 100  \
		--file-align=fill      \
		--line-numbers=1        \
		--borders=no             \
		--pro=color               \
		--left-title=""            \
		--pretty-print="$R/etc/lua.ssh" \
		--columns  2                 \
		-M letter                     \
		--footer=""                    \
		--right-footer=""               \
	  -o	 $@.ps $<
	ps2pdf $@.ps $@; rm $@.ps
	open $@


D=nasa93dem auto2 auto93 china coc1000 healthCloseIsses12mths0001-hard \
	healthCloseIsses12mths0011-easy pom SSN SSM

xys:
	$(foreach f,$D,printf "\n\n----[$f]-------------------\n"; \
		             lua keys.lua -f ../data/$f.csv -g xys;)

