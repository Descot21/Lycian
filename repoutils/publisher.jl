
struct Publisher
    root
    editorsrepo
    ict
    iiifsvc
    target
end


"""Create a Publisher structure for the given repository root.

$(SIGNATURES)
"""
function lycpublisher(root)
    repo = repository(root)
    ict = "http://www.homermultitext.org/ict2/?"
    # Citable Image service
    baseiifurl = "http://www.homermultitext.org/iipsrv"
    imgroot = "/project/homer/pyramidal/deepzoom"
    iiifsvc = IIIFservice(baseiifurl, imgroot)
    # Target for output
    textroot = root * "/offline/texts/" 
    Publisher(root, repo, ict, iiifsvc,textroot)
end


"""Publish complete website to testing directory `offline`.

$(SIGNATURES)

The `offline` directory has basic pages that can be published on github
by copying to the `docs` directory.  This function composes the following markdown pages
from source content in the repository:

1. `publishtexts` composes web pages for all cataloged editions of texts
2. `publisharticles` composes web pages for articles about divinites.  It takes the 
markdown in `divinities-articles`, and appends an automatically assembled index of 
occurrences of that divinity in the text corpus.
3. `publishconcordance` composes a concordance of all tokens in the text editions.
4. `publishlexicon` does something else.
"""
function publishsite(publisher::Publisher)
    @info("\nComposing complete web site for project.\n\n")
    publishtexts(publisher)
    publisharticles(publisher)
    publishconcordance(publisher)
    publishlexicon(publisher)
    msg = """\nComplete website constructed in directory `offline`.
If you have jekyll installed on your system, you can run a jekyll web server there.    
    """
    @info(msg)
end 
