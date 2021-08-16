
struct Publisher
    editorsrepo
    ict
    iiifsvc
    target
end


"""Create a Publisher structure for the given repository root.
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
    Publisher(repo, ict, iiifsvc,textroot)
end


function publishsite(reporoot)
    publishconcordance(reporoot)
    publisharticles(reporoot)
    publishtexts(reporoot)
end