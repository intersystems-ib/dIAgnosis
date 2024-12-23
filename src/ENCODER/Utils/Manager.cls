Class ENCODER.Utils.Manager Extends %RegisteredObject
{

ClassMethod GetEncoding(sentence As %String) As %String [ Language = python ]
{
        import sentence_transformers
        # create the model and form the embeddings
        model = sentence_transformers.SentenceTransformer('/iris-shared/model/')
        embeddings = model.encode(sentence, normalize_embeddings=True).tolist() # Convert search phrase into a vector
        # convert the embeddings to a string
        return str(embeddings)
}

ClassMethod DownloadModel() As %String [ Language = python ]
{
    import sentence_transformers

    model = sentence_transformers.SentenceTransformer('FremyCompany/BioLORD-2023-M')
    model.save('/iris-shared/model/')
    return "Downloaded"
}

}
