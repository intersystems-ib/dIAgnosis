Class ENCODER.Utils.Manager Extends %RegisteredObject
{

/// Description
ClassMethod CreateTable() As %Status
{
        Set sc = $$$OK
        
        set sqlCreateCode = "CREATE TABLE ENCODER_Object.Codes (CodeId VARCHAR(50), Description VECTOR(DECIMAL, 384), TypeCode VARCHAR(50))"
        set statementCreateCode = ##class(%SQL.Statement).%New()
        set statusCreateCode = statementCreateCode.%Prepare(sqlCreateCode)
        if ($$$ISOK(statusCreateCode)) {
            set resultSetCreateCode = statementCreateCode.%Execute()
        }
        Return sc
}

ClassMethod GetEncoding(sentence As %String) As %String [ Language = python ]
{
        import sentence_transformers
        # create the model and form the embeddings
        model = sentence_transformers.SentenceTransformer('/shared/model/')
        embeddings = model.encode(sentence, normalize_embeddings=True).tolist() # Convert search phrase into a vector
        # convert the embeddings to a string
        return str(embeddings)
}

ClassMethod DownloadModel() As %String [ Language = python ]
{
    import sentence_transformers

    model = sentence_transformers.SentenceTransformer('sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2')
    model.save('/shared/model/')
    return "Downloaded"
}

ClassMethod LematizeText(textToLematize As %String) As %String [ Language = python ]
{
    import spacy

    nlp = spacy.load('es_core_news_sm')

    doc = nlp(textToLematize)
    words = [t.orth_ for t in doc if not t.is_punct | t.is_stop]
    lexical_tokens = [t.lower() for t in words if t.isalpha()]
    
    return " ".join(lexical_tokens)
}

}
