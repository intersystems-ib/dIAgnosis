Class ENCODER.BP.AnalyzeTextProcess Extends Ens.BusinessProcess
{

Method OnRequest(pInput As ENCODER.Message.AnalysisRequest, Output pOutput As ENCODER.Message.AnalysisResponse) As %Status
{
        
        set pOutput = ##class(ENCODER.Message.AnalysisResponse).%New()
        set result = ..AnalyzeText(pInput.TextToAnalyze, pInput.%Id())
        set pOutput.AnalysisRequestId = pInput.%Id()
        return $$$OK
}

Method AnalyzeText(text As %String, id As %String) As %String [ Language = python ]
{
    import sentence_transformers
    import iris
    import spacy

    def lematizeText(textToLematize):        

        nlp = spacy.load('es_core_news_sm')
        doc = nlp(textToLematize)
        words = [t.orth_ for t in doc if not t.is_punct | t.is_stop]
        lexical_tokens = [t.lower() for t in words if t.isalpha()]
        
        return " ".join(lexical_tokens)

    model = sentence_transformers.SentenceTransformer('/shared/model/')
    phrases = text.split(",")
    for textToLematize in phrases :
        if textToLematize != "":
            phrase = lematizeText(textToLematize)
            result = ""
            words = phrase.split(" ")
            totalWords = len(words)

            i = 0
            texts = []
            while i + 3 <= totalWords :
                texts.append(words[i]+" "+words[i+1]+" "+words[i+2])
                i = i + 1
            i = 0
            while i + 4 <= totalWords :
                texts.append(words[i]+" "+words[i+1]+" "+words[i+2]+" "+words[i+3])
                i = i + 1
            
            if len(texts) == 0 :
                texts.append(phrase)

            embeddings = model.encode(texts, normalize_embeddings=True)
            embeddingList = embeddings.tolist()
            
            i = 0
            for text in texts:
                stmt = iris.sql.prepare("SELECT TOP 50 * FROM (SELECT CodeId, Description, VECTOR_DOT_PRODUCT(VectorDescription, TO_VECTOR(?, DECIMAL)) AS Similarity FROM ENCODER_Object.Codes) WHERE Similarity > 0.65 ORDER BY Similarity DESC")
                resultSet = stmt.execute(str(embeddingList[i]))
                df = resultSet.dataframe()
                if (df.size > 0):
                    for index, row in df.iterrows():
                        textMatch = iris.cls('ENCODER.Object.TextMatches')._New()
                        textMatch.RawText = text
                        textMatch.CodeId = str(row['codeid'])
                        textMatch.Description = str(row['description'])
                        textMatch.Similarity = str(row['similarity'])
                        textMatch.AnalysisId = id
                        status = textMatch._Save()
                        result = result + "|"+ text+"_"+ str(row['codeid'])+":"+ str(row['description'])+":"+ str(row['similarity'])
                i = i + 1

    return result
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
