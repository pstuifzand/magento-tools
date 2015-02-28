# Magento Tools

Tools for working with Magento in Vim.

## The tools

### magento-helper.pl

Works with a small Vim script to opens the file that contains the Block, Model
or Helper.

Specfically it looks for getModel(...), getBlock(...) or helper(...) calls on
the current line and calculates the location of the .php file from the
config.xml files.

### magento-helper

Short `config.xml` parser that lists Blocks, Helpers and Models.

### magento-modules

List all modules in `app/etc/modules`.

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

