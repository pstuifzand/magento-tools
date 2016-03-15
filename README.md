# Magento Tools

Tools for working with Magento in Vim.

## The tools

### magento-helper.pl

Works with a small Vim script to opens the file that contains the Block, Model
or Helper.

Specfically it looks for getModel(...), getBlock(...) or helper(...) calls on
the current line and calculates the location of the .php file from the
config.xml files.

#### Useful .vimrc commands

    function! TestMH()
        let filename = systemlist("echo " . shellescape(getline('.')) . " | ~/bin/magento-helper.pl")
        execute ":e " . filename[1]
        execute "/" . filename[0]
    endfunction

    function! MModel(name)
        let filename = systemlist("echo " . shellescape(a:name) . " | ~/bin/magento-helper.pl --model")
        execute ":e " . filename[1]
        execute "/" . filename[0]
    endfunction

    function! MBlock(name)
        let filename = systemlist("echo " . shellescape(a:name) . " | ~/bin/magento-helper.pl --block")
        execute ":e " . filename[1]
        execute "/" . filename[0]
    endfunction

    function! MHelper(name)
        let filename = systemlist("echo " . shellescape(a:name)) . " | ~/bin/magento-helper.pl --helper")
        execute ":e " . filename[1]
        execute "/" . filename[0]
    endfunction

    function! Rewrite(module)
        let filename = systemlist("rewrite.pl " . shellescape(expand('%')) . " " . a:module)
        execute ":e " . filename[0]
    endfunction

    command -nargs=1 MHelper :call MHelper(<args>)
    command -nargs=1 MBlock :call MBlock(<args>)
    command -nargs=1 MModel :call MModel(<args>)
    command -complete=custom,ListModules -nargs=1 Rewrite :call Rewrite("<args>")
    fun ListModules(A,L,P)
        return system("modules.sh")
    endfun


### magento-helper

Short `config.xml` parser that lists Blocks, Helpers and Models.

### magento-modules

List all modules in `app/etc/modules`.

### magento-config.pl files...

Checks getStoreConfig() calls for existence in all 'system.xml' files.

### xml-lister files...

List all elements and attributes from XML files.

### block-lister files...

### rewrite.pl filename

Let's you choose a module and rewrites the class by adding a few lines to your
config.xml and creates a new file in the right spot.

## Building

Uses the `expat` library.

Also uses C++11.

Build using make.

    make

## Vim

I use the following Vim function to call the script. Place the Perl program in
`~/bin` or change the path below. This part could use the most improvement.

    function! MagentoToolsFind()
        let filename = systemlist("echo " . shellescape(getline('.')) . " | perl ~/bin/magento-helper.pl")
        execute ":e " . filename[1]
        execute "/" . filename[0]
    endfunction

    nmap \k :call MagentoToolsFind()<cr>

## Also useful

### Fuzzy finder

* [fzf](https://github.com/junegunn/fzf)
* [fzf.vim](https://github.com/junegunn/fzf.vim)

### XML

* [XMLStarlet](http://xmlstar.sourceforge.net/)
* [XMLStarlet article](http://www.freesoftwaremagazine.com/articles/xml_starlet)
* [XSLT Identity transformation](http://www.usingxml.com/Transforms/XslIdentity)



### Bash command line functions

FZF in combination with modules.sh and themes.sh will also make for quick "cd".

    fmod() {
        root=`git rev-parse --show-toplevel`
        cd $root
        module=`modules.sh | fzf`
        if [[ $module && -d "app/code/$module" ]] 
        then
            cd app/code/$module
        fi
    }

    ftheme() {
        root=`git rev-parse --show-toplevel`
        cd $root
        theme=`themes.sh | fzf`
        if [[ $theme && -d "app/design/frontend/$theme" ]] 
        then
            cd app/design/frontend/$theme
        fi
    }

    gr() {
        root=`git rev-parse --show-toplevel`
        cd $root
    }


