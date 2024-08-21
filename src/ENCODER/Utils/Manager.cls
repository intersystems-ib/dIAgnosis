Class ENCODER.Utils.Manager Extends %RegisteredObject
{

/// Description
ClassMethod ExecuteInsertQuery(sqlQuery As %String) As %String
{
    Try {
        set statement = ##class(%SQL.Statement).%New()
        set status = statement.%Prepare(sqlQuery)
        if ($$$ISOK(status)) {
            set result = statement.%Execute()
            return result.%SQLCODE
        }
        else {
            return "0"
        }
    }
    Catch (ex) {
        return "0"
    }
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

    model = sentence_transformers.SentenceTransformer('FremyCompany/BioLORD-2023-M')
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
