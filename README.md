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

    command -nargs=1 MHelper :call MHelper(<args>)
    command -nargs=1 MBlock :call MBlock(<args>)
    command -nargs=1 MModel :call MModel(<args>)

### magento-helper

Short `config.xml` parser that lists Blocks, Helpers and Models.

### magento-modules

List all modules in `app/etc/modules`.

### magento-config.pl files...

Checks getStoreConfig() calls for existence in all 'system.xml' files.

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

* [fzf](https://github.com/junegunn/fzf)
* [fzf.vim](https://github.com/junegunn/fzf.vim)

