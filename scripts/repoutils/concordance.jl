
function indexcorpus(c)
    orthography = lycianAscii()
    concordance = []
    for n in c.corpus
        tkns = orthography.tokenizer(n.text)
        lextokens = filter(t -> t.tokencategory == Orthography.LexicalToken(), tkns)
        pairs = map(tkn -> (tkn.text, n.urn), lextokens)
        push!(concordance, pairs)
    end
    idx = collect(Iterators.flatten(concordance))
    terms = map(entry -> entry[1], idx)
    urns = map(entry -> entry[2], idx)
    df = DataFrame( term = terms, urn = urns,)
    groupby(df, :term)
end