Class ENCODER.BP.AnalyzeTextProcess Extends Ens.BusinessProcess
{

Method OnRequest(pInput As ENCODER.Message.AnalysisRequest, Output pOutput As ENCODER.Message.AnalysisResponse) As %Status
{
        
        set pOutput = ##class(ENCODER.Message.AnalysisResponse).%New()
        set result = ..AnalyzeText(pInput.TextToAnalyze, pInput.AnalysisId, pInput.LanguageSelected)
        set pOutput.AnalysisRequestId = pInput.AnalysisId
        return $$$OK
}

Method AnalyzeText(text As %String, analysisId As %String, language As %String) As %String [ Language = python ]
{
    import sentence_transformers
    import iris
    import spacy

    try:
        lematize = ''
        if language == 'es':
            lematize = 'es_core_news_sm'
        else:
            lematize = 'en_core_web_sm'

        nlp = spacy.load(lematize)

        model = sentence_transformers.SentenceTransformer('/shared/model/')
        phrases = text.split(",")
        sqlsentence = ""
        for textToLematize in phrases :
            if textToLematize != "":
                doc = nlp(textToLematize)
                words = [t.orth_ for t in doc if not t.is_punct | t.is_stop]
                lexical_tokens = [t.lower() for t in words if t.isalpha()]
                phrase = " ".join(lexical_tokens)
                result = ""
                words = phrase.split(" ")
                totalWords = len(words)
                i = 0
                texts = []
                while i + 3 <= totalWords :
                    texts.append(words[i]+" "+words[i+1]+" "+words[i+2])
                    i = i + 1
                if len(texts) == 0 :
                    texts.append(phrase)

                embeddings = model.encode(texts, normalize_embeddings=True)
                embeddingList = embeddings.tolist()
                i = 0
                for text in texts:
                    sqlsentence = "INSERT INTO ENCODER_Object.TextMatches (CodeId, Description, Similarity, AnalysisId, RawText) SELECT * FROM (SELECT CodeId, Description, VECTOR_DOT_PRODUCT(VectorDescription, TO_VECTOR('"+str(embeddingList[i])+"', DECIMAL)) AS Similarity, '"+analysisId+"', '"+text+"' FROM ENCODER_Object.Codes) WHERE Similarity > 0.8"
                     #iris.cls("Ens.Util.Log").LogInfo("ENCODER.BP.AnalyzeTextProcess", "AnalyzeText", sqlsentence)
                    iris.cls("ENCODER.Utils.Manager").ExecuteInsertQuery(sqlsentence)
                    i = i + 1
    except Exception as err:
        return repr(err)

    return "Success"
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
